var AWS = require('ti.aws');

var win = Ti.UI.createWindow({ backgroundColor: '#fff' });
var transferManager = AWS.createS3TransferManager();

// We cannot access files from the resources directory, so we copy it over before
var file = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, 'example.png');
var newFile = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'example.png');
newFile.write(file.read());

win.addEventListener('open', function () {
    transferManager.configure({
        region: AWS.REGION_US_WEST_1, // See the AWS docs for details
        poolId: 'YOUR_POOL_ID'
    });
});

var button = Ti.UI.createButton({ title: 'Upload' });

button.addEventListener('click', function () {    
    if (!newFile.exists()) {
        throw new Error('NO SUCH FILE');
    }

    transferManager.upload({
        file: newFile.nativePath,
        bucket: 'lambus',
        key: 'profiles/example-' + new Date().getTime() + '.png',
        success: function (event) {
            Ti.API.warn('SUCCESS!');
            Ti.API.warn(JSON.stringify(event));
        },
        error: function (event) {
            Ti.API.error('ERROR!');
            Ti.API.error(event);
        }
    });    
});

win.add(button);
win.open();