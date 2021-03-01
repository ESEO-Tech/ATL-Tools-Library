var clickedElements = new Array;
var nodeCounter = 1;
var mousePosition = {x: 0, y: 0};
var svgRoot = document.getElementsByTagName('svg')[0];

window.addEventListener('mousemove', ev => {
    mousePosition.x = ev.pageX;
    mousePosition.y = ev.pageY;
});

window.addEventListener('click', ev => {
    let nodeName = ev.target.localName;
    if (nodeName == "circle" ||  nodeName == "line") {
        let nodeId = ev.target.id.split('.')
        nodeId.pop();
        clickedElements.push(nodeId.join('.'));
    }
});

window.addEventListener("keypress", ev => {
    switch (ev.key) {
        case 'i': incNode(); break;
        case 'n': createNode(); break;
        case 'e': createArc(); break;
        case 'd': deleteLatest(); break;
    }
}, false);

function createNode() {
    let nodeName = 'node'+nodeCounter;
    nodeCounter++;

    let use = document.createSVGElement('use');
    use.setAttribute('id', nodeName);
    use.setAttribute('href', '#node');
    use.appendChild(createParam('label', nodeName));
    use.appendChild(createParam('xinit', mousePosition.x));
    use.appendChild(createParam('yinit', mousePosition.y));

    nodes.appendChild(use);
    tcsvg.addedUse(use);
}

function incNode() {
    if (clickedElements.length >= 1) {
        const nodeId = clickedElements.pop();
        const nodeUse = document.getElementById(nodeId);
        for(const p of nodeUse.children) {
            if(p.attributes.name.value === "label") {
                p.attributes.value.value += 1;
            }
        }
        tcsvg.addedUse(nodeUse);
    }
}

function createArc() {
    if (clickedElements.length >= 2) {
        let tgt = clickedElements.pop();
        if (tgt.includes('arc')) return;
        let src = clickedElements.pop();
        if (src.includes('arc')) return;
        if (src == tgt) return;
        let arcId = 'arc_' + src + '_' + tgt;

        if (document.getElementById(arcId) !== null) return;

        let use = document.createSVGElement('use');
        use.setAttribute('id', arcId);
        use.setAttribute('href', '#arc');
        use.appendChild(createParam('source', src));
        use.appendChild(createParam('target', tgt));

        arcs.appendChild(use);
        tcsvg.addedUse(use);
    }
}

function deleteLatest() {
    if (clickedElements.length >= 1) {
        let eltId = clickedElements.pop();
        let use = document.getElementById(eltId);

        clickedElements = clickedElements.filter(it => it !== eltId);

        if (eltId.includes('arc')) { // clicked element is a node
            arcs.removeChild(use);
            tcsvg.removedUse(use);
        }
        else {
            arcs.getElementsByTagName('use')
            .filter(node => node.id.includes(eltId))
            .forEach(node => {
                arcs.removeChild(node);
                tcsvg.removedUse(node);
                clickedElements = clickedElements.filter(it => it !== node.id);
            });
            nodes.removeChild(use);
            tcsvg.removedUse(use);
        }
    }
}

document.createSVGElement = function(name) {
    return document.createElementNS("http://www.w3.org/2000/svg", name);
}

function createParam(name, value) {
    let param = document.createSVGElement('param');
        param.setAttribute('name', name);
        param.setAttribute('value', value);

    return param;
}

var arcs = document.createSVGElement('g')
arcs.setAttribute('id', 'arcs');
svgRoot.appendChild(arcs);

var nodes = document.createSVGElement('g')
nodes.setAttribute('id', 'nodes');
svgRoot.appendChild(nodes);