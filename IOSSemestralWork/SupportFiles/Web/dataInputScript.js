function init(title, timeString, description) {
    document.getElementById(`title`).innerHTML = title;
    document.getElementById(`timeString`).innerHTML = timeString;
    document.getElementById(`description`).innerHTML = description;
    hideImage(true)
}

function showImage(img) {
    hideImage(false)
    
    // Source can be either local image or a webpage
    document.getElementById(`image`).src = img;
}

function hideImage(bool) {
    document.getElementById(`image`).hidden = bool;
}
