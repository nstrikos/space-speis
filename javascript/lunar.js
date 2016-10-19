
Qt.include("three.js")

var camera, scene, renderer;
var distance;
var theta;
var phi;
var camera_x, camera_y, camera_z;
var dragging;
var start_x, start_y, end_x, end_y;
var theta0, phi0, delta_theta, delta_phi;
var frame = 0;
var positionVelocityArray;
var runSimulation = true;
var sphere;
var spotLight;
var phiAscending = true;
var m, PositionX, PositionY, PositionZ;
var VelocityX, VelocityY, VelocityZ;
var orbitGeometry, lineOrbit, orbitMaterial
var particleSystem;
var velGeometry, velLine, velMaterial;
var autoRotate, relativeMotion;
var velFactor;
var posX, posY, posZ;

var thetaSender = Qt.createQmlObject('import QtQuick 2.0; QtObject { signal thetaChanged(double value) }', Qt.application, 'ThetaSender');
var phiSender = Qt.createQmlObject('import QtQuick 2.0; QtObject { signal phiChanged(double value) }', Qt.application, 'PhiSender');
var draggingSender = Qt.createQmlObject('import QtQuick 2.0; QtObject { signal draggingSignal(bool value) }', Qt.application, 'DraggingSender');
var distanceSender = Qt.createQmlObject('import QtQuick 2.0; QtObject {signal distanceChanged(double value) }', Qt.application, 'DistanceSender');


function initializeGL(canvas, eventSource) {

    scene = new THREE.Scene();

    initVariables();
    evaluateArray();

    //This is very important
    //Set camera length

    camera = new THREE.PerspectiveCamera( 45, canvas.width / canvas.height, 10, 5000000);
    camera.target = new THREE.Vector3(0, 0, 0);
    camera.position.set( camera_x, camera_y, camera_z);

    addReferencePlane();
    addSpheres();
    addLights();
    addOrbits();
    addVelocities();

    renderer = new THREE.Canvas3DRenderer(
                { canvas: canvas, antialias: true, devicePixelRatio: canvas.devicePixelRatio });
    renderer.setPixelRatio( canvas.devicePixelRatio );
    renderer.setSize( canvas.width, canvas.height );

    eventSource.mouseDown.connect(onDocumentMouseDown);
    eventSource.mouseUp.connect(onDocumentMouseUp);
    eventSource.mouseMove.connect(onDocumentMouseMove);
    eventSource.mouseWheel.connect(onDocumentMouseWheel);
}

function resizeGL(canvas) {

    renderer.setPixelRatio( canvas.devicePixelRatio );
    camera.aspect = canvas.width / canvas.height;
    camera.updateProjectionMatrix ();
    renderer.setSize( canvas.width, canvas.height );
}

function paintGL(canvas) {

//    if (frame < positionVelocityArray.length - 1 ) {
//        if (runSimulation == true)
//            frame++;
//    }

//    var sphere1X;
//    var sphere1Y;
//    var sphere1Z;
//    var sphere2X;
//    var sphere2Y;
//    var sphere2Z;
//    var sphere1VelX;
//    var sphere1VelY;
//    var sphere1VelZ;
//    var sphere2VelX;
//    var sphere2VelY;
//    var sphere2VelZ;

//    if (!relativeMotion)
//    {


//        sphere1X = positionVelocityArray[frame][0];
//        sphere1Y = positionVelocityArray[frame][1];
//        sphere1Z = positionVelocityArray[frame][2];
//        sphere2X = positionVelocityArray[frame][3];
//        sphere2Y = positionVelocityArray[frame][4];
//        sphere2Z = positionVelocityArray[frame][5];
//        sphere1VelX = positionVelocityArray[frame][6];
//        sphere1VelY = positionVelocityArray[frame][7];
//        sphere1VelZ = positionVelocityArray[frame][8];
//        sphere2VelX = positionVelocityArray[frame][9];
//        sphere2VelY = positionVelocityArray[frame][10];
//        sphere2VelZ = positionVelocityArray[frame][11];
//    }
//    else
//    {
//        sphere1X = 0;
//        sphere1Y = 0;
//        sphere1Z = 0;
//        sphere1VelX = 0;
//        sphere1VelY = 0;
//        sphere1VelZ = 0;
//        sphere2X = positionVelocityArray[frame][3] - positionVelocityArray[frame][0];
//        sphere2Y = positionVelocityArray[frame][4] - positionVelocityArray[frame][1];
//        sphere2Z = positionVelocityArray[frame][5] - positionVelocityArray[frame][2];
//        sphere2VelX = positionVelocityArray[frame][9] - positionVelocityArray[frame][6];
//        sphere2VelY = positionVelocityArray[frame][10] - positionVelocityArray[frame][7];
//        sphere2VelZ = positionVelocityArray[frame][11] - positionVelocityArray[frame][8];
//    }

    sphere.position.x = posX;
    sphere.position.y = posY;
    sphere.position.z = posZ;
//    sphere2.position.x = sphere2X;
//    sphere2.position.y = sphere2Y;
//    sphere2.position.z = sphere2Z;

    if (dragging)
    {
        delta_theta = (end_x - start_x) * 0.01;
        delta_phi = (end_y - start_y) * 0.01;
    }
    else
    {
        delta_theta = 0;
        delta_phi = 0;
    }
    theta = theta0 - delta_theta;
    phi = phi0 + delta_phi;

    if (phi > Math.PI / 2)
        phi = Math.PI / 2;
    if (phi < Math.PI / 45)
        phi = Math.PI / 45;
    if (theta > Math.PI )
        theta = Math.PI ;
    if (theta < -Math.PI)
        theta = -Math.PI;

    thetaSender.thetaChanged(theta);
    phiSender.phiChanged(phi);

    camera_x = distance * Math.sin(theta)*Math.cos(phi);
    camera_z = distance * Math.cos(theta)*Math.cos(phi);
    camera_y = distance * Math.sin(phi);
    camera.position.x = camera_x;
    camera.position.z = camera_z;
    camera.position.y = camera_y;

//    //Light sphere
    spotLight.position.set(camera_x, camera_y, camera_z);

    camera.lookAt( scene.position );

//    //    var timer = 0.00000000000002 * Date.now();
//    //    if (frame < positionVelocityArray.length - 1 )
//    //        sphere2.rotation.y +=  timer;

    if (autoRotate)
    {
        theta0 += 0.001;
        if (theta0 > Math.PI)
            theta0 = -Math.PI;

        if (phiAscending)
        {
            phi0 += 0.001;
            if (phi0 > Math.PI / 2)
            {
                phi0 = Math.PI / 2
                phiAscending = false
            }
        }
        else
        {
            phi0 -= 0.001;
            if (phi0 < - Math.PI / 2)
            {
                phi0 = -Math.PI / 2;
                phiAscending = true;
            }
        }
    }



//    if (frame > 0)
//        {
//            for (var i = frame - 1; i < positionVelocityArray.length - 1; i++)
//            {
//                orbitGeometry.dynamic = true;
//                orbitGeometry2.dynamic = true;
//                orbitGeometry.vertices[i].x = sphere1X;
//                orbitGeometry.vertices[i].y = sphere1Y;
//                orbitGeometry.vertices[i].z = sphere1Z;
//                orbitGeometry2.vertices[i].x = sphere2X;
//                orbitGeometry2.vertices[i].y = sphere2Y;
//                orbitGeometry2.vertices[i].z = sphere2Z;
//            }
//        }
//        orbitGeometry.verticesNeedUpdate = true;
//        orbitGeometry2.verticesNeedUpdate = true;

//    //Particle system
//    //    var verts = particleSystem.geometry.vertices;
//    //    var vert = verts[frame];

//    //    if (!relativeMotion)
//    //    {
//    //        vert.x = positionVelocityArray[frame][0];
//    //        vert.y = positionVelocityArray[frame][1];
//    //        vert.z = positionVelocityArray[frame][2];
//    //    }
//    //    else
//    //    {
//    //        vert.x = 0;
//    //        vert.y = 0;
//    //        vert.z = 0;
//    //    }

//    //    particleSystem.geometry.verticesNeedUpdate = true;

//    //    var verts2 = particleSystem2.geometry.vertices;
//    //    var vert2 = verts2[frame];

//    //    if (!relativeMotion)
//    //    {
//    //        vert2.x = positionVelocityArray[frame][3];
//    //        vert2.y = positionVelocityArray[frame][4];
//    //        vert2.z = positionVelocityArray[frame][5];
//    //    }
//    //    else
//    //    {
//    //        vert2.x = positionVelocityArray[frame][3] - positionVelocityArray[frame][0];
//    //        vert2.y = positionVelocityArray[frame][4] - positionVelocityArray[frame][1];
//    //        vert2.z = positionVelocityArray[frame][5] - positionVelocityArray[frame][2];
//    //    }

//    //    particleSystem2.geometry.verticesNeedUpdate = true;

//    velGeometry.vertices[0].x = sphere1X;
//    velGeometry.vertices[0].y = sphere1Y;
//    velGeometry.vertices[0].z = sphere1Z;
//    velGeometry.vertices[1].x = sphere1X + sphere1VelX * velFactor;
//    velGeometry.vertices[1].y = sphere1Y + sphere1VelY * velFactor;
//    velGeometry.vertices[1].z = sphere1Z + sphere1VelZ * velFactor;
//    velGeometry.verticesNeedUpdate = true;
//    velGeometry2.vertices[0].x = sphere2X;
//    velGeometry2.vertices[0].y = sphere2Y;
//    velGeometry2.vertices[0].z = sphere2Z;
//    velGeometry2.vertices[1].x = sphere2X + sphere2VelX * velFactor;
//    velGeometry2.vertices[1].y = sphere2Y + sphere2VelY * velFactor;
//    velGeometry2.vertices[1].z = sphere2Z + sphere2VelZ * velFactor;
//    velGeometry2.verticesNeedUpdate = true;


    renderer.render( scene, camera );
}

function setTheta(value)
{
    theta0 = value;
}

function setPhi(value)
{
    phi0 = value;
}

function setDistance(value)
{
    distance = 16000 - value;
    if (distance < 4000)
        distance = 4000;
    if (distance > 16000)
        distance = 16000;
}

function onDocumentMouseDown(x, y) {
    start_x = x;
    start_y = y;
    end_x = x;
    end_y = y;
    theta0 = theta;
    phi0 = phi;
    delta_theta = 0;
    delta_phi = 0;
    dragging = true;
    draggingSender.draggingSignal(true);
}

function onDocumentMouseUp(x, y) {
    end_x = x;
    end_y = y;
    theta0 = theta;
    phi0 = phi;
    dragging = false;
    draggingSender.draggingSignal(false);
}

function onDocumentMouseMove(x, y) {
    end_x = x;
    end_y = y;
}

function onDocumentMouseWheel (a, b)
{
    if (b < 0) {
        distance -=10000;
    }
    else if (b > 0){
        distance += 10000;
    }
    if (distance < 4000)
        distance = 4000;
    if (distance > 700000)
        distance = 700000;

    distanceSender.distanceChanged(16000 - distance);
    console.log(distance);
}

function resetView()
{
    theta0 = -Math.PI / 8;
    phi0 = Math.PI / 4;
    distance = 8000;
}

function maxZRotation()
{
    setPhi(90);
}

function initVariables()
{
    //theta = theta0  = -Math.PI / 18;
    theta = theta0 = Math.PI / 8;
    delta_theta = 0.0;
    phi = phi0 = Math.PI / 4;
    delta_phi = 0.0;
    distance = 2355880;
    camera_x = distance*Math.sin(theta);
    camera_z = distance*Math.cos(theta);
    camera_y = distance * Math.sin(phi);

    dragging = false;
    start_x = start_y = end_x = end_y =  0;

    m = 0;

    velFactor = 80;

    orbitGeometry = new THREE.Geometry();
    orbitMaterial = new THREE.LineBasicMaterial({color: 0xff0049, linewidth: 2});
    velGeometry = new THREE.Geometry();
    velMaterial = new THREE.LineBasicMaterial({color: 0x00ffff, linewidth: 2});

    autoRotate = false;
    relativeMotion = false;
}

function evaluateArray()
{
    var x = 0;
    var xstop = 3000;
    var h = 1;
    var G = 6.67384e-20;

    //rk4(x, xstop, h, y, m1, m2, G, positionVelocityArray, nrows);

    frame = 0;
}

function addLights()
{
    // add subtle ambient lighting
    var ambiColor = "#5c5c5c";
    var ambientLight = new THREE.AmbientLight(ambiColor);
    scene.add(ambientLight);

    var spotColor = "#8f8f8f";
    spotLight = new THREE.SpotLight(spotColor);
    spotLight.position.set(0, 0, 0);
    spotLight.castShadow = true;
    spotLight.target = sphere;
    scene.add(spotLight);
}

function addSpheres()
{
    var sphereGeometry = new THREE.SphereGeometry(20000, 30, 30);
    var material = new THREE.MeshPhongMaterial({color: 0xff7777});

    sphere = new THREE.Mesh(sphereGeometry, material);
    sphere.name = "sphere";
    scene.add(sphere);
    sphere.position.y = 300;

    sphere.frustumCulled = false;
}

function addReferencePlane()
{
    var redMaterial = new THREE.LineBasicMaterial({
        color: 0xff0000,
        linewidth: 5.0
    });

    var redGeometry = new THREE.Geometry();
    redGeometry.vertices.push(
        new THREE.Vector3( 0, 0, 0 ),
        new THREE.Vector3( 500000, 0, 0 )
    );

    var redLine = new THREE.Line( redGeometry, redMaterial );
    scene.add( redLine );

    var greenMaterial = new THREE.LineBasicMaterial({
        color: 0x00ff00,
        linewidth: 5.0
    });

    var greenGeometry = new THREE.Geometry();
    greenGeometry.vertices.push(
        new THREE.Vector3( 0, 0, 0 ),
        new THREE.Vector3( 0, 500000, 0 )
    );

    var greenLine = new THREE.Line( greenGeometry, greenMaterial );
    scene.add( greenLine );

    var blueMaterial = new THREE.LineBasicMaterial({
        color: 0x0000ff,
        linewidth: 5.0
    });

    var blueGeometry = new THREE.Geometry();
    blueGeometry.vertices.push(
        new THREE.Vector3( 0, 0, 0 ),
        new THREE.Vector3( 0, 0, 500000 )
    );

    var blueLine = new THREE.Line( blueGeometry, blueMaterial );
    scene.add( blueLine );

    var texture = THREE.ImageUtils.loadTexture("qrc:/images/ground.jpg");


    var planeGeometry = new THREE.PlaneBufferGeometry( 500000, 500000 );
    var planeMaterial = new THREE.MeshPhongMaterial({
                                                        map: THREE.ImageUtils.loadTexture("../images/ground.jpg"),
                                                        side: THREE.DoubleSide,
                                                        transparent: true,
                                                        opacity: 0.8
                                                    });
    var plane = new THREE.Mesh(planeGeometry, planeMaterial);
    plane.rotation.x =  Math.PI / 2;

    scene.add( plane );
}

function evaluate(mass1, mass2, x1, y1, z1, x2, y2, z2, velx1, vely1, velz1, velx2, vely2, velz2)
{
    m1 = mass1;
    m2 = mass2;
    Mass1PositionX = x1;
    Mass1PositionY = y1;
    Mass1PositionZ = z1;
    Mass2PositionX = x2;
    Mass2PositionY = y2;
    Mass2PositionZ = z2;
    Mass1VelocityX = velx1;
    Mass1VelocityY = vely1;
    Mass1VelocityZ = velz1;
    Mass2VelocityX = velx2;
    Mass2VelocityY = vely2;
    Mass2VelocityZ = velz2;

    clearOrbits();

    positionVelocityArray = [];
    delete positionVelocityArray;
    positionVelocityArray = null;
    //scene.remove(line);
    //delete line;
    //line = null;
    evaluateArray();
    runSimulation = true;
}

function addOrbits()
{

//    for (var i = 0; i < positionVelocityArray.length - 1; i++)
//    {
//        orbitGeometry.vertices.push(new THREE.Vector3(undefined, undefined, undefined));
//    }
//    lineOrbit = new THREE.Line(orbitGeometry, orbitMaterial);
//    lineOrbit.name = "lineOrbit";
//    scene.add(lineOrbit);

//    lineOrbit.frustumCulled = false;


    //Particle system

    //    var particleCount = positionVelocityArray.length,
    //            particles = new THREE.Geometry(),
    //            pMaterial = new THREE.PointCloudMaterial({
    //                                                         color: 0xff0049,
    //                                                         size: 40
    //                                                    });
    //    for (var p = 0; p < particleCount; p++) {
    //        var    particle = new THREE.Vector3(0, 0, 0);
    //        particles.vertices.push(particle);
    //    }

    //    particleSystem = new THREE.PointCloud(particles, pMaterial);
    //    scene.add(particleSystem);

    //    var particleCount2 = positionVelocityArray.length,
    //            particles2 = new THREE.Geometry(),
    //            pMaterial2 = new THREE.PointCloudMaterial({
    //                                                          color: 0x4900ff,
    //                                                          size: 40
    //                                                      });

    //    for (p = 0; p < particleCount; p++) {
    //        var    particle2 = new THREE.Vector3(0, 0, 0);
    //        particles2.vertices.push(particle2);
    //    }

    //    particleSystem2 = new THREE.PointCloud(
    //                particles2,
    //                pMaterial2);
    //    scene.add(particleSystem2);
}

function addVelocities()
{
    velGeometry.vertices.push(new THREE.Vector3(undefined, undefined, undefined));
    velGeometry.vertices.push(new THREE.Vector3(undefined, undefined, undefined));
    velLine =  new THREE.Line(velGeometry, velMaterial);
    scene.add(velLine);

    velLine.frustumCulled = false;
}

function setRotate(value)
{
    autoRotate = value;
}

function setRelativeMotion(value)
{
    relativeMotion = value;
    clearOrbits();
    positionVelocityArray = [];
    delete positionVelocityArray;
    positionVelocityArray = null;
    evaluateArray();
}

function setVelFactor(value)
{
    velFactor = value;
}

function restart()
{
    frame = 0;
}

function setSphere1X(value)
{
    frame = 0;
    runSimulation = false;
    positionVelocityArray[frame][0] = value;
    clearOrbits();
}

function setSphere1Y(value)
{
    frame = 0;
    runSimulation = false;
    positionVelocityArray[frame][1] = value;
    clearOrbits();
}

function setSphere1Z(value)
{
    frame = 0;
    runSimulation = false;
    positionVelocityArray[frame][2] = value;
    clearOrbits();
}

function setSphere2X(value)
{
    frame = 0;
    runSimulation = false;
    positionVelocityArray[frame][3] = value;
    clearOrbits();
}

function setSphere2Y(value)
{
    frame = 0;
    runSimulation = false;
    positionVelocityArray[frame][4] = value;
    clearOrbits();
}

function setSphere2Z(value)
{
    frame = 0;
    runSimulation = false;
    positionVelocityArray[frame][5] = value;
    clearOrbits();
}

function setPosX(value)
{
    posX = value;
}

function setPosY(value)
{
    posY = value;
}

function setPosZ(value)
{
    posZ = value;
}


function clearOrbits()
{
        for (var i = 0; i < positionVelocityArray.length - 1; i++)
        {
            orbitGeometry.dynamic = true;
            orbitGeometry2.dynamic = true;
            orbitGeometry.vertices[i].x = 0;
            orbitGeometry.vertices[i].y = 0;
            orbitGeometry.vertices[i].z = 0;
            orbitGeometry2.vertices[i].x = 0;
            orbitGeometry2.vertices[i].y = 0;
            orbitGeometry2.vertices[i].z = 0;
        }

        orbitGeometry.verticesNeedUpdate = true;
        orbitGeometry2.verticesNeedUpdate = true;


    //Particle system
//    var particleCount = positionVelocityArray.length;
//    var verts = particleSystem.geometry.vertices;
//    var verts2 = particleSystem2.geometry.vertices;
//    for (var i = 0; i < particleCount; i++)
//    {
//        var vert = verts[i];
//        var vert2 = verts2[i];
//        vert.x = 0;
//        vert.y = 0;
//        vert.z = 0;
//        vert2.x = 0;
//        vert2.y = 0;
//        vert2.z = 0;
//    }
//    particleSystem.geometry.verticesNeedUpdate = true;
//    particleSystem2.geometry.verticesNeedUpdate = true;
}
