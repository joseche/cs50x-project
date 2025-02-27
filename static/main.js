const $ = function (id) {
    return document.getElementById(id);
};

window.onload = function () {
    //assign button behavior to functions
    // $("topline").onclick = myCalendar;
    $("year").onchange = myCalendar;
    $("month").onchange = myCalendar;
    myCalendar();
};
//User input function (calendar creation based on user inputs)
function myCalendar() {
    const year = $("year").value;
    const month = $("month").value;
    //invoke new calendar
    new Calendar("cal", year, month);
}
//Calendar creator function
function Calendar(id, year, month) {
    //assign var elem to the div in which calendar will be drawn.
    //In this case, #cal
    const elem = $("cal");

    // (1) Get Date: month -1 because counter starts at 0. So if you enter 12, the date object will look for a 13th month. So minus 1 so if you enter 12, you get dec.
    const mon = month - 1;

    const d = new Date(year, mon);

    //start table drawing
    let table = ["<table><tr>"];

    // (2) get start day of month and fill first row
    //  0  1  2  3  4  5  6
    for (let i = 0; i < d.getDay(); i++) {
        table.push("<td></td>");
    }

    // main body (3) //fill in rest of rows based on month
    while (d.getMonth() == mon) {
        table.push("<td>" + d.getDate() + "</td>");

        // (4)if 7 days in the week to be filled- create rows.
        if (d.getDay() % 7 == 6) {
            table.push("</tr><tr>");
        }

        //set date: add 1 because counter starts at 0, but our days start at 1..
        //so add 1.
        d.setDate(d.getDate() + 1);
    }

    // (5) if less than 7 days, blank spaces
    for (let i = d.getDay(); i < 7; i++) {
        table.push("<td></td>");
    }
    // table closure
    table.push("</tr></table>");

    //join all rows created above to create complete table and draw.
    elem.innerHTML = table.join("\n");
}
