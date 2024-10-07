$(document).ready(function() {
    $('#navbar-placeholder').load('nav.html');

    const labName = localStorage.getItem('lab');
    const userName = localStorage.getItem('userName');
    const dataPath = localStorage.getItem('dataPath');

    if (labName || userName || dataPath) {
        document.getElementById('lab').value = labName;
        document.getElementById('name').value = userName;
        document.getElementById('path').value = dataPath;
        console.log('Data loaded from Local Storage');
    } else {
        console.log('No data found in Local Storage');
    }

    $('#confirm').on('click', function() {
        let labName = $('#lab').val();
        let experimenterName = $('#name').val();
        let savePath = $('#path').val();
        if (labName && experimenterName && savePath) {
            // Process or save the experimenterName and savePath
            localStorage.setItem('lab', labName);
            localStorage.setItem('userName', experimenterName);
            localStorage.setItem('dataPath', savePath);

            window.location.href = 'patients.html';
        } else {
            alert("Please enter all required information.");
        }
    });

});
