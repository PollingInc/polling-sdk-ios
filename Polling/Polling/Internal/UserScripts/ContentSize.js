(function (document, console) {
    function handleResize(e) {
        console.log(`document.body.scrollHeight = ${document.body.scrollHeight}`)
    }
    document.body.addEventListener('resize', handleResize);
})(document, console);
