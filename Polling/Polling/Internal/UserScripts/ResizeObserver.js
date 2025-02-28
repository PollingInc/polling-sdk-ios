(function (document, console) {
    const htmlRoot = document.documentElement;
    const observer = new ResizeObserver(function(elms) {
        console.log(`height=${htmlRoot.getBoundingClientRect().height}`);
        for (const elm of elms)
            console.log(elm)
            /* console.log(Object.getPrototypeOf(elm));*/

    });
    observer.observe(htmlRoot);
})(document, console);
