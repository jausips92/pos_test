const SHEET_ID = '1Ku0jeMB1VOI5Uryeqt5dgghAQbOccMdJyPLtSpxnJAU';
const HEADERS = ['category', 'name', 'price'];
const ORDER_SEQUENCE_SHEET = 'pos_order_sequence';

function doGet(e) {
  const action = e && e.parameter && e.parameter.action;
  if (action === 'nextOrderNumber') {
    return handleNextOrderNumber(e.parameter.dateCode);
  }
  return jsonResponse({ ok: true, message: 'POS menu sync is ready.' });
}

function doPost(e) {
  try {
    const payload = JSON.parse((e && e.postData && e.postData.contents) || '{}');
    if (payload.action === 'replaceMenu') {
      return handleReplaceMenu(payload);
    }
    if (payload.action === 'nextOrderNumber') {
      return handleNextOrderNumber(payload.dateCode);
    }
    throw new Error('Unsupported action');
  } catch (error) {
    return jsonResponse({ ok: false, error: String(error.message || error) });
  }
}

function handleReplaceMenu(payload) {
  const rows = Array.isArray(payload.rows) ? payload.rows : [];
  const values = rows
    .map((row) => [
      String(row.category || '').trim(),
      String(row.name || '').trim(),
      Number(row.price),
    ])
    .filter((row) => row[0] && row[1] && Number.isFinite(row[2]));

  const spreadsheet = SpreadsheetApp.openById(SHEET_ID);
  const sheet = spreadsheet.getSheets()[0];
  sheet.clearContents();
  sheet.getRange(1, 1, values.length + 1, HEADERS.length).setValues([HEADERS, ...values]);

  return jsonResponse({ ok: true, count: values.length });
}

function handleNextOrderNumber(dateCode) {
  const safeDateCode = String(dateCode || '').trim();
  if (!/^\d{6}$/.test(safeDateCode)) {
    throw new Error('Invalid dateCode');
  }

  const lock = LockService.getScriptLock();
  lock.waitLock(10000);
  try {
    const spreadsheet = SpreadsheetApp.openById(SHEET_ID);
    const sheet = getOrCreateSequenceSheet(spreadsheet);
    const values = sheet.getDataRange().getValues();
    let rowIndex = -1;
    let sequence = 0;

    for (let i = 1; i < values.length; i++) {
      if (String(values[i][0]) === safeDateCode) {
        rowIndex = i + 1;
        sequence = Number(values[i][1]) || 0;
        break;
      }
    }

    const next = sequence + 1;
    if (rowIndex === -1) {
      sheet.appendRow([safeDateCode, next, new Date()]);
    } else {
      sheet.getRange(rowIndex, 2, 1, 2).setValues([[next, new Date()]]);
    }

    return jsonResponse({
      ok: true,
      dateCode: safeDateCode,
      sequence: next,
      orderNumber: safeDateCode + String(next).padStart(4, '0'),
    });
  } finally {
    lock.releaseLock();
  }
}

function getOrCreateSequenceSheet(spreadsheet) {
  let sheet = spreadsheet.getSheetByName(ORDER_SEQUENCE_SHEET);
  if (!sheet) {
    sheet = spreadsheet.insertSheet(ORDER_SEQUENCE_SHEET);
    sheet.getRange(1, 1, 1, 3).setValues([['dateCode', 'sequence', 'updatedAt']]);
  }
  return sheet;
}

function jsonResponse(data) {
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}
