(function (document) {
    var style = document.createElement('style');
    document.head.appendChild(style);
    try { style.dataset.injectedBySdk = 'Polling SDK for iOS'; } catch {};
    style.textContent = '/*__CSS__*/';
})(document);
