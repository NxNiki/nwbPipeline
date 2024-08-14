$(document).ready(function() {
    $('#add-patient').on('click', function() {
        // Open a new window for adding patient information
        // window.open('add_patient.html', 'Add Patient', 'width=600,height=400');
        // Redirect to the add_patient.html page instead of opening a new window
        window.location.href = 'add_patient.html';
    });
});