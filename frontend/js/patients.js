$(document).ready(function() {
    $('#navbar-placeholder').load('nav.html');
    
    const patients = getPatients();

    function renderPatientsTable(patients) {
        const tbody = $('#patients-table tbody');
        tbody.empty(); // Clear any existing rows

        patients.forEach(patient => {
            const row = `
                <tr>
                    <td>${patient.id}</td>
                    <td>${patient.name}</td>
                    <td>${patient.sex}</td>
                    <td>${patient.birthData}</td>
                    <td><button class="view-button" data-id="${patient.id}">View Status</button></td>
                    <td><button class="edit-button" data-id="${patient.id}">Edit</button></td>
                </tr>
            `;
            tbody.append(row);
        });

        // Add event listeners to the edit buttons
        $('#edit-button').on('click', function() {
            const patientId = $(this).data('id');
            editPatient(patientId);
        });

        $('#view-button').on('click', function() {
            const patientId = $(this).data('id');
            viewPatient(patientId);
        })

        $('#add-patient').on('click', function() {
            addPatient();
        })
    }

    // Render the table on page load
    renderPatientsTable(patients);

});


function getPatients() {

    const savePath = localStorage.getItem("path");
    const patients = [
        { id: 1, name: 'John Doe', sex: 'Male', birthDate: '1900-1-1' },
        { id: 2, name: 'Jane Smith', sex: 'Female', birthDate: '1900-1-1' },
        // Add more patient data here
    ];

    return patients;

}

function savePatients(patients) {

    const savePath = localStorage.getItem("path");


}

function editPatient(id) {
    console.log(`Edit patient with ID: ${id}`);
    // Add your edit logic here
}

function viewPatient(id) {
    console.log(`View patient: ${id}`);
}

function addPatient() {
    console.log('add patient')
    window.location.href = 'add_patient.html';
}