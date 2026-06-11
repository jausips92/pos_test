const SHEET_ID = '1Ku0jeMB1VOI5Uryeqt5dgghAQbOccMdJyPLtSpxnJAU';
const HEADERS = ['category', 'name', 'price'];

function doGet() {
  return jsonResponse({ ok: true, message: 'POS menu sync is ready.' });
}

function doPost(e) {
  try {
    const payload = JSON.parse((e && e.postData && e.postData.contents) || '{}');
    if (payload.action !== 'replaceMenu') {
      throw new Error('Unsupported action');
    }

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
  } catch (error) {
    return jsonResponse({ ok: false, error: String(error.message || error) });
  }
}

function jsonResponse(data) {
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}
