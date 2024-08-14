$(document).ready(function() {
    let experimentCount = 1;

    // Function to add a new experiment field
    $('#add-experiment').on('click', function() {
        experimentCount++;
        const experimentHTML = `
            <div class="experiment">
                <label for="experiment-name-${experimentCount}">Experiment Name:</label>
                <select id="experiment-name-${experimentCount}" name="experiment-name-${experimentCount}">
                    <option value="exp1">Experiment 1</option>
                    <option value="exp2">Experiment 2</option>
                    <option value="exp3">Experiment 3</option>
                </select>
                <button class="remove-experiment">Remove</button>
            </div>
        `;
        $('#experiments').append(experimentHTML);
    });

    // Function to remove an experiment field
    $('#experiments').on('click', '.remove-experiment', function() {
        $(this).parent('.experiment').remove();
    });
});
