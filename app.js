const STORAGE_KEY = "restaurant-pos-v1";
const LOCAL_SEQUENCE_KEY = "restaurant-pos-order-sequence-v1";

const seedData = {
  categories: [
    { id: "cat-drinks", name: "飲料" },
    { id: "cat-main", name: "主餐" },
    { id: "cat-side", name: "小菜" },
    { id: "cat-extra", name: "加料" },
  ],
  products: [
    { id: "p-black-tea", categoryId: "cat-drinks", name: "古早味紅茶", price: 30 },
    { id: "p-milk-tea", categoryId: "cat-drinks", name: "招牌奶茶", price: 45 },
    { id: "p-lemon", categoryId: "cat-drinks", name: "檸檬青茶", price: 50 },
    { id: "p-rice", categoryId: "cat-main", name: "滷肉飯", price: 55 },
    { id: "p-noodle", categoryId: "cat-main", name: "牛肉湯麵", price: 120 },
    { id: "p-chicken", categoryId: "cat-main", name: "椒麻雞飯", price: 135 },
    { id: "p-tofu", categoryId: "cat-side", name: "皮蛋豆腐", price: 45 },
    { id: "p-greens", categoryId: "cat-side", name: "燙青菜", price: 40 },
    { id: "p-egg", categoryId: "cat-extra", name: "滷蛋", price: 15 },
    { id: "p-noodles-extra", categoryId: "cat-extra", name: "加麵", price: 20 },
  ],
  printerIp: "",
};

let state = loadState();
let activeView = "order";
let activeCategoryId = state.categories[0]?.id ?? "";
let activeAdminCategoryId = state.categories[0]?.id ?? "";
let cart = {};
let pendingConfirm = null;
let activeReceipt = null;

const $ = (selector) => document.querySelector(selector);

const elements = {
  railButtons: document.querySelectorAll(".rail-button"),
  views: document.querySelectorAll(".view"),
  categoryTabs: $("#category-tabs"),
  productGrid: $("#product-grid"),
  orderSummary: $("#order-summary"),
  cartList: $("#cart-list"),
  cartCount: $("#cart-count"),
  cartTotal: $("#cart-total"),
  clearCart: $("#clear-cart"),
  checkout: $("#checkout"),
  clock: $("#clock"),
  printerForm: $("#printer-form"),
  printerIp: $("#printer-ip"),
  printerStatus: $("#printer-status"),
  testPrinter: $("#test-printer"),
  categoryAdminList: $("#category-admin-list"),
  productAdminList: $("#product-admin-list"),
  productPanelTitle: $("#product-panel-title"),
  addCategory: $("#add-category"),
  addProduct: $("#add-product"),
  categoryDialog: $("#category-dialog"),
  categoryForm: $("#category-form"),
  categoryDialogTitle: $("#category-dialog-title"),
  categoryId: $("#category-id"),
  categoryName: $("#category-name"),
  productDialog: $("#product-dialog"),
  productForm: $("#product-form"),
  productDialogTitle: $("#product-dialog-title"),
  productId: $("#product-id"),
  productName: $("#product-name"),
  productPrice: $("#product-price"),
  productCategory: $("#product-category"),
  receiptDialog: $("#receipt-dialog"),
  receiptPreview: $("#receipt-preview"),
  receiptPrintRoot: $("#receipt-print-root"),
  closeReceipt: $("#close-receipt"),
  printReceipt: $("#print-receipt"),
  finishReceipt: $("#finish-receipt"),
  confirmDialog: $("#confirm-dialog"),
  confirmTitle: $("#confirm-title"),
  confirmMessage: $("#confirm-message"),
  confirmOk: $("[data-confirm-ok]"),
  confirmCancel: $("[data-confirm-cancel]"),
  toast: $("#toast"),
};

function loadState() {
  const saved = localStorage.getItem(STORAGE_KEY);
  if (!saved) return structuredClone(seedData);

  try {
    const parsed = JSON.parse(saved);
    return {
      categories: Array.isArray(parsed.categories) ? parsed.categories : seedData.categories,
      products: Array.isArray(parsed.products) ? parsed.products : seedData.products,
      printerIp: parsed.printerIp || "",
    };
  } catch {
    return structuredClone(seedData);
  }
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function currency(value) {
  return `$${Number(value || 0).toLocaleString("zh-TW")}`;
}

function id(prefix) {
  return `${prefix}-${Date.now()}-${Math.random().toString(16).slice(2, 7)}`;
}

function showToast(message) {
  elements.toast.textContent = message;
  elements.toast.classList.add("show");
  window.clearTimeout(showToast.timer);
  showToast.timer = window.setTimeout(() => elements.toast.classList.remove("show"), 1800);
}

function confirmAction({ title, message, okText = "確認" }) {
  elements.confirmTitle.textContent = title;
  elements.confirmMessage.textContent = message;
  elements.confirmOk.textContent = okText;
  elements.confirmDialog.showModal();
  return new Promise((resolve) => {
    pendingConfirm = resolve;
  });
}

function closeDialog(dialog) {
  dialog.close();
}

function setView(view) {
  activeView = view;
  elements.railButtons.forEach((button) => {
    button.classList.toggle("active", button.dataset.view === view);
  });
  elements.views.forEach((panel) => {
    panel.classList.toggle("active", panel.id === `${view}-view`);
  });
  render();
}

function render() {
  if (!state.categories.some((category) => category.id === activeCategoryId)) {
    activeCategoryId = state.categories[0]?.id ?? "";
  }
  if (!state.categories.some((category) => category.id === activeAdminCategoryId)) {
    activeAdminCategoryId = state.categories[0]?.id ?? "";
  }

  renderCategories();
  renderProducts();
  renderCart();
  renderPrinterSettings();
  renderAdmin();
}

function renderCategories() {
  elements.categoryTabs.innerHTML = "";

  if (!state.categories.length) {
    elements.categoryTabs.innerHTML = `<div class="empty-state">尚未建立類別</div>`;
    return;
  }

  state.categories.forEach((category) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `category-tab${category.id === activeCategoryId ? " active" : ""}`;
    button.textContent = category.name;
    button.addEventListener("click", () => {
      activeCategoryId = category.id;
      render();
    });
    elements.categoryTabs.append(button);
  });
}

function renderProducts() {
  const products = state.products.filter((product) => product.categoryId === activeCategoryId);
  elements.productGrid.innerHTML = "";

  if (!state.categories.length) {
    elements.productGrid.innerHTML = `<div class="empty-state">請先到商品頁新增類別</div>`;
    elements.orderSummary.textContent = "尚無類別";
    return;
  }

  if (!products.length) {
    elements.productGrid.innerHTML = `<div class="empty-state">此類別尚無商品</div>`;
    elements.orderSummary.textContent = "可到商品頁新增品項";
    return;
  }

  const categoryName = state.categories.find((category) => category.id === activeCategoryId)?.name ?? "";
  elements.orderSummary.textContent = `${categoryName} · ${products.length} 個商品`;

  products.forEach((product) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "product-button";
    button.innerHTML = `
      <span class="product-name">${escapeHtml(product.name)}</span>
      <span class="product-price">${currency(product.price)}</span>
    `;
    button.addEventListener("click", () => addToCart(product.id));
    elements.productGrid.append(button);
  });
}

function addToCart(productId) {
  const product = state.products.find((item) => item.id === productId);
  if (!product) return;
  cart[productId] = (cart[productId] || 0) + 1;
  renderCart();
}

function changeQuantity(productId, delta) {
  const nextQuantity = (cart[productId] || 0) + delta;
  if (nextQuantity <= 0) {
    delete cart[productId];
  } else {
    cart[productId] = nextQuantity;
  }
  renderCart();
}

function cartItems() {
  return Object.entries(cart)
    .map(([productId, quantity]) => {
      const product = state.products.find((item) => item.id === productId);
      return product ? { ...product, quantity, subtotal: product.price * quantity } : null;
    })
    .filter(Boolean);
}

function renderCart() {
  const items = cartItems();
  const totalQuantity = items.reduce((sum, item) => sum + item.quantity, 0);
  const total = items.reduce((sum, item) => sum + item.subtotal, 0);

  elements.cartCount.textContent = `${totalQuantity} 項`;
  elements.cartTotal.textContent = currency(total);
  elements.cartList.innerHTML = "";

  if (!items.length) {
    elements.cartList.innerHTML = `<div class="empty-state">購物車尚無商品</div>`;
    elements.clearCart.disabled = true;
    elements.checkout.disabled = true;
    return;
  }

  elements.clearCart.disabled = false;
  elements.checkout.disabled = false;

  items.forEach((item) => {
    const row = document.createElement("div");
    row.className = "cart-row";
    row.innerHTML = `
      <strong>${escapeHtml(item.name)}</strong>
      <span>${currency(item.price)}</span>
      <div class="quantity-control">
        <button class="quantity-button" type="button" aria-label="減少 ${escapeHtml(item.name)}">-</button>
        <strong>${item.quantity}</strong>
        <button class="quantity-button" type="button" aria-label="增加 ${escapeHtml(item.name)}">+</button>
      </div>
      <span class="line-total">${currency(item.subtotal)}</span>
    `;
    const [minusButton, plusButton] = row.querySelectorAll(".quantity-button");
    minusButton.addEventListener("click", () => changeQuantity(item.id, -1));
    plusButton.addEventListener("click", () => changeQuantity(item.id, 1));
    elements.cartList.append(row);
  });
}

function renderPrinterSettings() {
  elements.printerIp.value = state.printerIp;
}

function renderAdmin() {
  renderCategoryAdmin();
  renderProductAdmin();
  renderProductCategoryOptions();
}

function renderCategoryAdmin() {
  elements.categoryAdminList.innerHTML = "";
  if (!state.categories.length) {
    elements.categoryAdminList.innerHTML = `<div class="empty-state">尚無類別</div>`;
    return;
  }

  state.categories.forEach((category) => {
    const productCount = state.products.filter((product) => product.categoryId === category.id).length;
    const row = document.createElement("div");
    row.className = `admin-item selectable${category.id === activeAdminCategoryId ? " selected" : ""}`;
    row.innerHTML = `
      <div class="admin-item-main">
        <strong>${escapeHtml(category.name)}</strong>
        <span>${productCount} 個商品</span>
      </div>
      <div class="item-actions">
        <button class="icon-button" type="button" title="修改">改</button>
        <button class="icon-button delete" type="button" title="刪除">刪</button>
      </div>
    `;
    const [editButton, deleteButton] = row.querySelectorAll("button");
    row.addEventListener("click", () => {
      activeAdminCategoryId = category.id;
      renderAdmin();
    });
    editButton.addEventListener("click", (event) => {
      event.stopPropagation();
      openCategoryDialog(category);
    });
    deleteButton.addEventListener("click", (event) => {
      event.stopPropagation();
      deleteCategory(category);
    });
    elements.categoryAdminList.append(row);
  });
}

function renderProductAdmin() {
  const selectedCategory = state.categories.find((category) => category.id === activeAdminCategoryId);
  const visibleProducts = selectedCategory
    ? state.products.filter((product) => product.categoryId === selectedCategory.id)
    : [];

  elements.productPanelTitle.textContent = selectedCategory
    ? `${selectedCategory.name}商品`
    : "商品";
  elements.productAdminList.innerHTML = "";

  if (!state.categories.length) {
    elements.productAdminList.innerHTML = `<div class="empty-state">請先新增類別</div>`;
    return;
  }

  if (!visibleProducts.length) {
    elements.productAdminList.innerHTML = `<div class="empty-state">此類別尚無商品</div>`;
    return;
  }

  visibleProducts.forEach((product) => {
    const categoryName = state.categories.find((category) => category.id === product.categoryId)?.name ?? "未分類";
    const row = document.createElement("div");
    row.className = "admin-item";
    row.innerHTML = `
      <div class="admin-item-main">
        <strong>${escapeHtml(product.name)} · ${currency(product.price)}</strong>
        <span>${escapeHtml(categoryName)}</span>
      </div>
      <div class="item-actions">
        <button class="icon-button" type="button" title="修改">改</button>
        <button class="icon-button delete" type="button" title="刪除">刪</button>
      </div>
    `;
    const [editButton, deleteButton] = row.querySelectorAll("button");
    editButton.addEventListener("click", () => openProductDialog(product));
    deleteButton.addEventListener("click", () => deleteProduct(product));
    elements.productAdminList.append(row);
  });
}

function renderProductCategoryOptions() {
  elements.productCategory.innerHTML = "";
  state.categories.forEach((category) => {
    const option = document.createElement("option");
    option.value = category.id;
    option.textContent = category.name;
    elements.productCategory.append(option);
  });
}

function openCategoryDialog(category = null) {
  elements.categoryDialogTitle.textContent = category ? "修改類別" : "新增類別";
  elements.categoryId.value = category?.id ?? "";
  elements.categoryName.value = category?.name ?? "";
  elements.categoryDialog.showModal();
  elements.categoryName.focus();
}

async function deleteCategory(category) {
  const productCount = state.products.filter((product) => product.categoryId === category.id).length;
  const ok = await confirmAction({
    title: "刪除類別",
    message: productCount
      ? `「${category.name}」內有 ${productCount} 個商品，刪除後商品也會一起移除。`
      : `確定刪除「${category.name}」？`,
    okText: "刪除",
  });
  if (!ok) return;

  state.categories = state.categories.filter((item) => item.id !== category.id);
  state.products = state.products.filter((product) => product.categoryId !== category.id);
  Object.keys(cart).forEach((productId) => {
    if (!state.products.some((product) => product.id === productId)) delete cart[productId];
  });
  saveState();
  render();
  showToast("類別已刪除");
}

function openProductDialog(product = null) {
  if (!state.categories.length) {
    showToast("請先新增類別");
    return;
  }

  elements.productDialogTitle.textContent = product ? "修改商品" : "新增商品";
  elements.productId.value = product?.id ?? "";
  elements.productName.value = product?.name ?? "";
  elements.productPrice.value = product?.price ?? "";
  elements.productCategory.value = product?.categoryId ?? activeAdminCategoryId ?? activeCategoryId;
  elements.productDialog.showModal();
  elements.productName.focus();
}

async function deleteProduct(product) {
  const ok = await confirmAction({
    title: "刪除商品",
    message: `確定刪除「${product.name}」？`,
    okText: "刪除",
  });
  if (!ok) return;

  state.products = state.products.filter((item) => item.id !== product.id);
  delete cart[product.id];
  saveState();
  render();
  showToast("商品已刪除");
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function isValidIp(value) {
  const parts = value.trim().split(".");
  return parts.length === 4 && parts.every((part) => /^\d+$/.test(part) && Number(part) >= 0 && Number(part) <= 255);
}

async function testPrinterConnection() {
  const ip = elements.printerIp.value.trim();
  elements.printerStatus.className = "status-line";

  if (!isValidIp(ip)) {
    elements.printerStatus.textContent = "請輸入正確 IP 格式";
    elements.printerStatus.classList.add("error");
    return;
  }

  elements.printerStatus.textContent = "測試中...";
  try {
    const controller = new AbortController();
    const timer = window.setTimeout(() => controller.abort(), 1800);
    await fetch(`http://${ip}`, { mode: "no-cors", signal: controller.signal });
    window.clearTimeout(timer);
    elements.printerStatus.textContent = "已送出測試請求";
    elements.printerStatus.classList.add("success");
  } catch {
    elements.printerStatus.textContent = "連線失敗或裝置無回應";
    elements.printerStatus.classList.add("error");
  }
}

function formatDateParts(date = new Date()) {
  const year = String(date.getFullYear());
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  const hour = String(date.getHours()).padStart(2, "0");
  const minute = String(date.getMinutes()).padStart(2, "0");
  const second = String(date.getSeconds()).padStart(2, "0");
  return { year, month, day, hour, minute, second };
}

function receiptDateCode(date = new Date()) {
  const { year, month, day } = formatDateParts(date);
  return `${year.slice(2)}${month}${day}`;
}

function formatPrintTime(date = new Date()) {
  const { year, month, day, hour, minute, second } = formatDateParts(date);
  return `${year}-${month}-${day} ${hour}:${minute}:${second}`;
}

async function nextOrderNumber() {
  try {
    const response = await fetch("/api/order-number", { method: "POST" });
    if (response.ok) {
      const data = await response.json();
      if (data.orderNumber) return data.orderNumber;
    }
  } catch {
    // Direct file usage falls back to local sequence.
  }

  const today = receiptDateCode();
  const saved = JSON.parse(localStorage.getItem(LOCAL_SEQUENCE_KEY) || "{}");
  const nextSequence = saved.date === today ? Number(saved.sequence || 0) + 1 : 1;
  localStorage.setItem(LOCAL_SEQUENCE_KEY, JSON.stringify({ date: today, sequence: nextSequence }));
  return `${today}${String(nextSequence).padStart(4, "0")}`;
}

function buildReceiptHtml(receipt) {
  const itemRows = receipt.items
    .map(
      (item) => `
        <div class="receipt-row">
          <span class="receipt-name">${escapeHtml(item.name)}</span>
          <span class="receipt-qty">x${item.quantity}</span>
          <span class="receipt-price">${Number(item.price).toLocaleString("zh-TW")}</span>
        </div>
      `,
    )
    .join("");

  return `
    <div class="receipt-line">================================</div>
    <div class="receipt-order">單號:${escapeHtml(receipt.orderNumber)}</div>
    <div class="receipt-line">================================</div>
    <div class="receipt-columns">
      <span>品項</span>
      <span>數量</span>
      <span>單價</span>
    </div>
    ${itemRows}
    <div class="receipt-line">================================</div>
    <div class="receipt-time">列印時間:${escapeHtml(receipt.printTime)}</div>
  `;
}

async function openReceiptPreview() {
  const items = cartItems();
  if (!items.length) return;

  const now = new Date();
  activeReceipt = {
    orderNumber: await nextOrderNumber(),
    printTime: formatPrintTime(now),
    items,
  };

  const receiptHtml = buildReceiptHtml(activeReceipt);
  elements.receiptPreview.innerHTML = receiptHtml;
  elements.receiptPrintRoot.innerHTML = `<div class="receipt-paper">${receiptHtml}</div>`;
  elements.receiptDialog.showModal();
}

function printActiveReceipt() {
  if (!activeReceipt) return;
  document.body.classList.add("printing");
  window.setTimeout(() => {
    window.print();
    window.setTimeout(() => document.body.classList.remove("printing"), 300);
  }, 50);
}

function finishReceipt() {
  activeReceipt = null;
  cart = {};
  elements.receiptPreview.innerHTML = "";
  elements.receiptPrintRoot.innerHTML = "";
  closeDialog(elements.receiptDialog);
  renderCart();
  showToast("已完成此筆訂單");
}

function updateClock() {
  elements.clock.textContent = new Intl.DateTimeFormat("zh-TW", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).format(new Date());
}

elements.railButtons.forEach((button) => button.addEventListener("click", () => setView(button.dataset.view)));

elements.clearCart.addEventListener("click", async () => {
  if (!cartItems().length) return;
  const ok = await confirmAction({
    title: "清空購物車",
    message: "確定清除目前已點商品？",
    okText: "清空",
  });
  if (!ok) return;
  cart = {};
  renderCart();
  showToast("購物車已清空");
});

elements.checkout.addEventListener("click", openReceiptPreview);
elements.printReceipt.addEventListener("click", printActiveReceipt);
elements.finishReceipt.addEventListener("click", finishReceipt);
elements.closeReceipt.addEventListener("click", () => closeDialog(elements.receiptDialog));

elements.printerForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const ip = elements.printerIp.value.trim();
  if (!isValidIp(ip)) {
    elements.printerStatus.textContent = "請輸入正確 IP 格式";
    elements.printerStatus.className = "status-line error";
    return;
  }
  state.printerIp = ip;
  saveState();
  elements.printerStatus.textContent = "設定已儲存";
  elements.printerStatus.className = "status-line success";
});

elements.testPrinter.addEventListener("click", testPrinterConnection);
elements.addCategory.addEventListener("click", () => openCategoryDialog());
elements.addProduct.addEventListener("click", () => openProductDialog());

elements.categoryForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const name = elements.categoryName.value.trim();
  if (!name) return;

  const categoryId = elements.categoryId.value;
  if (categoryId) {
    state.categories = state.categories.map((category) => (category.id === categoryId ? { ...category, name } : category));
  } else {
    const nextCategory = { id: id("cat"), name };
    state.categories.push(nextCategory);
    activeCategoryId = nextCategory.id;
    activeAdminCategoryId = nextCategory.id;
  }

  saveState();
  closeDialog(elements.categoryDialog);
  render();
  showToast("類別已儲存");
});

elements.productForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const name = elements.productName.value.trim();
  const price = Number(elements.productPrice.value);
  const categoryId = elements.productCategory.value;

  if (!name || Number.isNaN(price) || price < 0 || !categoryId) return;

  const productId = elements.productId.value;
  if (productId) {
    state.products = state.products.map((product) =>
      product.id === productId ? { ...product, name, price, categoryId } : product,
    );
  } else {
    state.products.push({ id: id("p"), name, price, categoryId });
  }

  activeCategoryId = categoryId;
  activeAdminCategoryId = categoryId;
  saveState();
  closeDialog(elements.productDialog);
  render();
  showToast("商品已儲存");
});

document.querySelectorAll("[data-close-dialog]").forEach((button) => {
  button.addEventListener("click", () => closeDialog(button.closest("dialog")));
});

elements.confirmOk.addEventListener("click", () => {
  closeDialog(elements.confirmDialog);
  pendingConfirm?.(true);
  pendingConfirm = null;
});

elements.confirmCancel.addEventListener("click", () => {
  closeDialog(elements.confirmDialog);
  pendingConfirm?.(false);
  pendingConfirm = null;
});

elements.confirmDialog.addEventListener("cancel", () => {
  pendingConfirm?.(false);
  pendingConfirm = null;
});

updateClock();
window.setInterval(updateClock, 10000);
render();
