var rgbStart = [139, 195, 74]
var rgbEnd = [183, 28, 28]

$(function () {
    window.addEventListener('message', function (event) {

        let locationn = event.data.locationn;
        let days = event.data.days;

        $("#streetDisplay").text(locationn);
        $("#dateDisplay").text(days);


        if (event.data.action == "setTalking") {
            setTalking(event.data.value)
        } else if (event.data.action == "setProximity") {
            setProximity(event.data.value)
        } else if (event.data.action == "toggle") {
            if (event.data.show) {
                $('#ui').show();
            } else {
                $('#ui').hide();
            }
        } else if (event.data.action == "moveHudd") {
            if (event.data.show) {
                $('#huddd').animate({
                    left: "200px"
                })
            } else {
                $('#huddd').animate({
                    left: "-100px"
                })
            }

        }
    });

});


// funckcje pod voice

function setProximity(value) {
    var color;
    var speaker;
    if (value == "whisper") {
        // color = "#35205D";
        speaker = 1;
    } else if (value == "normal") {
        // color = "#35205D"
        speaker = 2;
    } else if (value == "shout") {
        // color = "#35205D"
        speaker = 3;

    }
    $('#voice img').attr('src', 'img/speaker' + speaker + '.png');
}

function setTalking(value) {
    if (value) {
        //#64B5F6
        $('#voice').css('border', '3px solid #bf002f')
    } else {
        //#81C784
        $('#voice').css('border', 'none')
    }
}