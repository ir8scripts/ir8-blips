var currentEvent = false;
var debug = false;
var blips = [];
var categories = [];
var selectedCategory = false;
var selectedCategoryId = "";

/**
 * Prints information to the console
 */
function debugPrint (txt) {
    if (debug) {
        console.log(txt);
    }
}

/**
 * Perform request to the resource
 */
async function nuiRequest (path, data = {}) {

    // Support for stringified json objects being passed
    if (typeof data == "string") {
        data = JSON.parse(decodeURIComponent(data))
    }

    return $.ajax({
        url: `https://${GetParentResourceName()}/${path}`,
        type: 'POST',
        dataType: 'json',
        data: JSON.stringify(data)
    });
}

function loadPage (type) {
    $('.page').hide();
    $(`#${type}-page`).show();

    if (type == "category") {
        $('#category-form').hide();
        $('#form').hide();
        $('#modal .modal-side').hide();
    } else {
        $('#category-form').hide();
        $('#form').hide();
        $('#modal .modal-side').hide();
    }
}

/**
 * Shows error and hides NUI
 */
function fatalError (txt) {
    debugPrint(txt);
    nuiRequest('hide');
}

function getCategoryNameById (categoryId) {
    var name = "None";

    for (let i = 0; i < categories.length; i++) {
        if (categories[i].id == categoryId) {
            name = categories[i].title;
        }
    }

    return name;
}

async function toggleCategory (id) {
    const res = await nuiRequest('category_enabled', {
        id: id,
        enabled: $(`#category_enabled_${id}`).is(':checked') ? 1 : 0
    });

    if (res.success) {
        if (res.message) {
            showMainAlert(res.message, 'success');
        }
    } else {
        showMainAlert('Something went wrong with your request. Please try again.', 'success');
    }
}

/**
 * Lists configurable blips
 */
function listCategories () {
    debugPrint("List categories");
    
    if (debug) {
        console.log(JSON.stringify(blips))
    }

    // Reset 

    $('#category-list').html('');
    $('#category_id').html('');

    // Add all option

    $('#category-list').append(`
        <div class="col-lg-4 category">
            <div onclick="loadCategoryBlips(false, 'All');" class="title-container rounded border border-1 text-center w-100">
                <span>All</span>
            </div>
        </div>
    `);

    $('#category_id').append('<option value="" selected="selected">No Category</option>');

    categories.forEach((item, key) => {
        $('#category-list').append(`
            <div class="col-lg-4 category">
                <div class="w-100 category-container">
                    <div onclick="loadCategoryBlips(${item.id}, '${item.title}');" class="title-container rounded border border-1 text-center w-100">
                        <span>${item.title}</span>
                    </div>

                    <div class="category-options">
                        <div class="w-100 text-start">
                            <div class="form-check form-switch" onclick="toggleCategory(${item.id});">
                                <input class="form-check-input" type="checkbox" role="switch" id="category_enabled_${item.id}" ${item.enabled == 1 ? 'checked' : ''}>
                                <label class="form-check-label" for="category_enabled_${item.id}">Enabled</label>
                            </div>
                        </div>

                        <div class="w-100 text-end">
                            <a href="javascript:void(0);" onclick="editCategory(${item.id}, '${item.title}');" class="btn btn-outline-light btn-sm"><i class="fas fa-pencil-alt"></i></a>
                        </div>
                    </div>
                </div>
            </div>
        `);

        $('#category_id').append(`<option value="${item.id}">${item.title}</option>`);
    });

    // Creation option

    $('#category-list').append(`
        <div class="col-lg-4 category">
            <div onclick="openCategoryForm(true);" class="title-container rounded border border-1 text-center w-100">
                <i class="fas fa-plus"></i>
            </div>
        </div>
    `);
}

function editCategory (id, title) {
    $('#category-title').val(title);
    $('#category-action').val('update');
    $('#category-id').val(id)
    openCategoryForm();
}

/**
 * Delets a blip category
 */
async function deleteCategory (deleteBlips = false) {

    const id = $('#category-id').val();

    if (!id) {
        return showCategoryAlert('Unable to delete category. Please select the category and try again.', 'danger');
    }

    const res = await nuiRequest('category_delete', { id: id, deleteBlips: deleteBlips });

    if (!res.success) {
        return showMainAlert("Unable to delete blip");
    }

    closeCategoryForm();
    selectedCategoryId = false;

    return showMainAlert("Category" + (deleteBlips ? " and it's blips " : " ") + "was deleted successfully", 'success');
}

async function loadCategoryBlips (id, title) {
    const res = await nuiRequest('category_blips', {
        categoryId: id
    });

    if (res.success && res.blips) {
        blips = res.blips;
        $('#blip-category-title').html(title);

        if (id) {
            selectedCategoryId = id;
        } else {
            selectedCategoryId = "";
        }

        listBlips();
        loadPage('blips');
    }

    return true;
}

/**
 * Lists configurable blips
 */
function listBlips () {
    debugPrint("List blips");
    
    if (debug) {
        console.log(JSON.stringify(blips))
    }

    $('#blips-list').html('');

    if (blips.length == 0) {
        return $('#blips-list').html(`
            <tr>
                <td colspan="4">No blips to list at this time.</td>
            </tr>
        `);
    }

    blips.forEach((item, key) => {
        const catTitle = getCategoryNameById(item.category_id);

        $('#blips-list').append(`
            <tr>
                <td><b>${item.title}</b></td>
                <td>${catTitle}</td>
                <td><a href="javascript:void(0);" onclick="teleport(${item.positionX}, ${item.positionY}, ${item.positionZ})" class="btn btn-primary btn-sm"><i class="fas fa-location-arrow"></i></a>&nbsp;&nbsp; ${item.positionX}, ${item.positionY}, ${item.positionZ}</td>
                <td class="text-end">
                    <a href="javascript:void(0);" onclick="updateBlip(${key});" class="btn btn-primary"><i class="fas fa-pencil-alt"></i></a>&nbsp;&nbsp;
                    <a href="javascript:void(0);" onclick="deleteBlip(${item.id});" class="btn btn-danger"><i class="fas fa-trash"></i></a>
                </td>
            </tr>
        `);
    });
}

/**
 * Shows alert on main window
 */
function showMainAlert (txt, type = "danger") {
    $('#main-alert').hide();
    $('#main-alert').removeClass('alert-danger').removeClass('alert-warning').removeClass('alert-success');
    $('#main-alert').addClass(`alert-${type}`);
    $('#main-alert').html(txt).show();
}

/**
 * Shows alert on side bar
 */
function showCategoryAlert (txt, type = "danger") {
    $('#category-alert').hide();
    $('#category-alert').removeClass('alert-danger').removeClass('alert-warning').removeClass('alert-success');
    $('#category-alert').addClass(`alert-${type}`);
    $('#category-alert').html(txt).show();
}

/**
 * Shows alert on side bar
 */
function showAlert (txt, type = "danger") {
    $('#alert').hide();
    $('#alert').removeClass('alert-danger').removeClass('alert-warning').removeClass('alert-success');
    $('#alert').addClass(`alert-${type}`);
    $('#alert').html(txt).show();
}

/**
 * Sends teleport request for a specific blip
 */
function teleport (x, y, z) {
    nuiRequest('teleport', { x, y, z });
}

/**
 * Delets a blip
 */
async function deleteBlip (id) {
    if (!id) {
        return showMainAlert("Unable to delete blip");
    }

    const res = await nuiRequest('delete', { id: id, selectedCategoryId });

    if (!res.success) {
        return showMainAlert("Unable to delete blip");
    }

    return showMainAlert("Blip was deleted successfully", 'success');
}

function openCategoryForm (create = false) {
    $('#form').hide();

    if (create) {
        resetCategoryForm();
        $('#header-title').html('Create Category');
        $('#delete-category-options').hide();
    } else {
        $('#header-title').html('Manage Category');
        $('#delete-category-options').show();
    } 

    $('#category-form').show();
    $('#modal .modal-side').show();
}

function closeCategoryForm () {
    resetCategoryForm();
    $('#form').hide();
    $('#category-form').hide();
    $('#category-id').val('');
    $('#modal .modal-side').hide();
}

function resetCategoryForm () {
    $('#form').hide();
    $('#category-form').hide();
    $('#modal .modal-side').hide();
    $('#category-title').val('');
    $('#category-action').val('create');
    $('#category-id').val('')
}


/**
 * Resets blip form
 */
function resetForm () {
    $('#category-form').show();
    $('#form').hide();
    $('#modal .modal-side').hide();
    $('#action').val('create');
    $('#id').val('');
    $('#title').val('');
    $('#position').val('');
    $('#blip_id').val('9');
    $('#color').val('18');
    $('#display').val('');
    $('#short_range').val('');
    $('#scale').val('0.5');

    $('.blip-preview')
        .css('background-image', 'url(nui://' + GetParentResourceName() + '/nui/images/blips/9.png)')
        .css('background-size', 'contain')
        .css('background-repeat', 'no-repeat')
        .css('background-position', 'center center')
        .show();
}

/**
 * Sets the form for a specific blip and it's data
 */
function updateBlip (key) {
    const data = blips[key];

    $('#action').val('update');
    $('#id').val(data.id);
    $('#title').val(data.title);
    $('#position').val(data.positionX + ', ' + data.positionY + ', ' + data.positionZ);
    $('#blip_id').val(data.blip_id);
    $('#color').val(data.color);
    $('#display').val(data.display);
    $('#short_range').val(data.short_range);
    $('#scale').val(data.scale);

    $('.blip-preview')
        .css('background-image', 'url(nui://' + GetParentResourceName() + '/nui/images/blips/' + data.blip_id + '.png)')
        .css('background-size', 'contain')
        .css('background-repeat', 'no-repeat')
        .css('background-position', 'center center')
        .show();

    $('#category-form').hide();
    $('#category_id').val(data.category_id ? data.category_id : "");

    $('#header-title').html('Manage Blip');

    $('#form').show();
    $('#modal .modal-side').show();
}

function setTheme (data) {
    

    /**
     * Handle custom theme
     */
    if (data.theme) {

        debugPrint(`Theme was sent`);

        if (debug) {
            console.log(JSON.stringify(data.theme));
        }

        if (data.theme.Title) {
            $('.title-container > .title').html(data.theme.Title)
        }

        if (data.theme.Colors.Background) {
            $('#modal .modal-content').css('background-color', data.theme.Colors.Background);
        }

        if (data.theme.Colors.Text) {
            $('body').css('color', data.theme.Colors.Text);
            $('.action').css('color', data.theme.Colors.Text);
        }
    }
}

/**
 * Message event handler from resource
 */
window.addEventListener('message', function(event){

    // Set the current event
    currentEvent = event;

    // If data action is not provided
    if (!event.data.action) { return false; } 

    /**
     * Sets prereqs for script
     */
    if (event.data.action == "init") {

        if (event.data.debug) {
            debug = event.data.debug
            debugPrint("Setting debug to " + debug);
        }

        setTheme(event.data);
    }

    /**
     * Updates data for script
     */
    if (event.data.action == "category_update") {
        if (!event.data.categories) {
            return fatalError("event.data.categories was not provided.");
        }

        if (!Array.isArray(event.data.categories)) {
            return fatalError("event.data.categories is not an array.");
        }

        categories = event.data.categories;
        listCategories();
    }

    /**
     * Updates data for script
     */
    if (event.data.action == "update") {
        if (!event.data.blips) {
            return fatalError("event.data.blips was not provided.");
        }

        if (!Array.isArray(event.data.blips)) {
            return fatalError("event.data.blips is not an array.");
        }

        blips = event.data.blips;
        listBlips();
    }

    /**
     * Shows modal and lists blips
     */
    if (event.data.action == "show") {

        if (!event.data.categories) {
            return fatalError("event.data.categories was not provided.");
        }

        if (!Array.isArray(event.data.categories)) {
            return fatalError("event.data.categories is not an array.");
        }

        setTheme(event.data);

        $('#category-alert, #main-alert, #alert').hide();

        categories = event.data.categories;
        listCategories();
        loadPage('category');

        $('#modal').css({ display: 'flex' });
    }

    /**
     * ======================================
     * Hide and clear
     * ======================================
     */
    if (event.data.action == "hide") {
        $('#modal').fadeOut();
    }
});

$(document).ready(function () {

    // Close button in header
    $('.actionable').on('click', function () {
        nuiRequest('hide');
    })

    // When esc key is pressed
    $(document).on("keyup", function(e) {
        if (e.key == "Escape") {
            nuiRequest('hide');
       }
    });

    // Opens the creation/modification form
    $('#open-form').on('click', function (e) {
        e.preventDefault();
        resetForm();
        $('#category-form').hide();
        $('#category_id').val(selectedCategoryId);
        $('#form').show();
        $('#header-title').html('Create Blip');
        $('#modal .modal-side').show();
    })

    // Closes the creation/modification form
    $('#close-form').on('click', function (e) {
        e.preventDefault();
        $('#category-form').hide();
        $('#form').hide();
        $('#modal .modal-side').hide();
    })

    // Fills the current position of player on form
    $('#fill-position').on('click', async function (e) {
        e.preventDefault();

        const res = await nuiRequest('position');

        if (res.position) {
            $($(this).data('target')).val(res.position);
        }
    })

    $('#blip_id').on('change', function () {
        if (!$(this).val()) {
            $('.blip-preview').hide();
        } else {
            $('.blip-preview')
                .css('background-image', 'url(nui://' + GetParentResourceName() + '/nui/images/blips/' + $(this).val() + '.png)')
                .css('background-size', 'contain')
                .css('background-repeat', 'no-repeat')
                .css('background-position', 'center center')
                .show();
        }
    })

    // Submits the form
    $('#category-form').on('submit', async function (e) {
        e.preventDefault();

        // Get all vars
        const action = $('#category-action').val();
        const id = $('#category-id').val();
        const title = $('#category-title').val();

        if (action == "update" && !id) {
            return showCategoryAlert("Something went wrong, please select blip again.");
        }

        if (!title) {
            return showCategoryAlert("The title is required.");
        }

        // Create the data object
        const data = {
            title
        }

        // Set id if updating
        if (action == "update" && id) {
            data.id = id;
        }

        debugPrint(JSON.stringify(data));
        const res = await nuiRequest(action == "update" ? 'category_update' : 'category_create', data);

        if (!res.success) {

            if (res.error) {
                return showCategoryAlert(res.error);
            } else {
                return showCategoryAlert("Unable to " + (action == "update" ? 'update' : 'create') + " category.");
            }
        }

        $('#category-form').hide();
        $('#modal .modal-side').hide();
        resetCategoryForm();

        return showMainAlert("Category was created successfully", 'success');
    })

    // Submits the form
    $('#form').on('submit', async function (e) {
        e.preventDefault();

        // Get all vars
        const action = $('#action').val();
        const id = $('#id').val();
        const title = $('#title').val();
        const position = $('#position').val();
        const blip_id = $('#blip_id').val();
        const color = $('#color').val();
        const display = $('#display').val();
        const short_range = $('#short_range').val();
        const scale = $('#scale').val();
        const job = $('#job').val();
        const category_id = $('#category_id').val();

        if (action == "update" && !id) {
            return showAlert("Something went wrong, please select blip again.");
        }

        if (!title) {
            return showAlert("The title is required.");
        }

        if (!position) {
            return showAlert("The position is required.");
        }

        if (!blip_id) {
            return showAlert("The blip id is required.");
        }

        if (!color) {
            return showAlert("The color is required.");
        }

        if (!display) {
            return showAlert("The display is required.");
        }

        if (!short_range) {
            return showAlert("Short range option is required.");
        }

        // Create the data object
        const data = {
            title,
            position,
            blip_id,
            color,
            display,
            short_range,
            scale,
            job,
            category_id,
            selectedCategoryId
        }

        // Set id if updating
        if (action == "update" && id) {
            data.id = id;
        }

        debugPrint(JSON.stringify(data));
        const res = await nuiRequest(action == "update" ? 'update' : 'create', data);

        if (!res.success) {

            if (res.error) {
                return showAlert(res.error);
            } else {
                return showAlert("Unable to " + (action == "update" ? 'update' : 'create') + " blip.");
            }
        }

        $('#form').hide();
        $('#modal .modal-side').hide();
        resetForm();

        return showMainAlert("Blip was created successfully", 'success');
    })
})