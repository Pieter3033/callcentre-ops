    document.addEventListener('DOMContentLoaded', function () {
        var table = document.getElementById('myTable');
        table.addEventListener('click', function (event) {
            var target = event.target;
            // Check if the clicked element is a table cell
            if (target.tagName === 'TD') {
                // Get the Jobcard value from the data attribute
                var id = target.parentElement.getAttribute('data-id');
                // Do something with the jobcard value, e.g., redirect to a URL
                window.location.href = 'edit_selected_1.sql?id=' + encodeURIComponent(id);
            }
        });
    });