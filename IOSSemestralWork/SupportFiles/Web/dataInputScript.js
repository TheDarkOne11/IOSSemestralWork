function init(title, timeString, description) {
    document.getElementById(`title`).innerHTML = title;
    document.getElementById(`timeString`).innerHTML = timeString;
    document.getElementById(`description`).innerHTML = description;
    document.getElementById(`image`).hidden = true;
}

function showImage(img) {
    document.getElementById(`image`).hidden = false;
    
    // Source can be either local image or a webpage
    document.getElementById(`image`).src = img;
}
