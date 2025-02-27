/*-------------------------
Main code taken from:
BVAmbient - VanillaJS Particle Background
https://bmsvieira.github.io/BVAmbient/
--------------------------- */

let isPaused = false;

class BVAmbient {
    constructor(
        selector,
        particle_number,
        fps,
        max_transition_speed,
        min_transition_speed,
        particle_maxwidth,
        particle_minwidth,
        particle_radius,
        particle_colision_change,
        particle_background,
        particle_image,
        responsive,
        particle_opacity,
        refresh_onfocus
    ) {
        // Define Variables
        this.selector = selector;
        this.particle_number = particle_number;
        this.fps = fps;
        (this.max_transition_speed = max_transition_speed),
            (this.min_transition_speed = min_transition_speed),
            (this.particle_maxwidth = particle_maxwidth);
        this.particle_minwidth = particle_minwidth;
        this.particle_radius = particle_radius;
        this.particle_colision_change = particle_colision_change;
        this.particle_background = particle_background;
        this.particle_image = particle_image;
        this.responsive = responsive;
        this.particle_opacity = particle_opacity;
        this.refresh_onfocus = refresh_onfocus;

        // Global Variables
        let particle_x_ray = [];

        // Add movement to particle
        this.MoveParticle = function (element) {
            let isresting = 1;

            // Moving Directions
            let top_down = ["top", "down"];
            let left_right = ["left", "right"];

            // Random value to decide wich direction follow
            let direction_h = Math.floor(Math.random() * (1 - 0 + 1)) + 0;
            let direction_v = Math.floor(Math.random() * (1 - 0 + 1)) + 0;

            // Direction
            let d_h = left_right[direction_h];
            let d_v = top_down[direction_v];

            let pos = 0,
                ver = 0,
                element_width = element.offsetWidth;
            let rect_main = document.getElementById(selector);

            // Change particle size
            function ChangeParticle(particle) {
                // Check if random color is enabled, change particle color when colides
                if (particle_background == "random") {
                    particle.style.backgroundColor = getRandomColor();
                }

                // Get random number based on the width and height of main div
                let RandomWidth =
                    Math.random() * (particle_maxwidth - particle_minwidth) +
                    particle_minwidth;
                particle.style.width = RandomWidth + "px";
                particle.style.height = RandomWidth + "px";
            }

            // Set frame to move particle
            function SetFrame() {
                if (!isPaused) {
                    setTimeout(SetFrame, 1000 / fps);
                }

                // Element offset positioning
                pos = element.offsetTop;
                ver = element.offsetLeft;

                // Check colision bounds
                if (pos == rect_main.offsetHeight - element_width) {
                    d_v = "top";
                    pos = rect_main.offsetHeight - element_width;
                    isresting = 1;
                    if (particle_colision_change == true) {
                        ChangeParticle(element);
                    } // Change Particle Size on colision
                }
                if (pos <= 0) {
                    d_v = "down";
                    pos = 0;
                    isresting = 1;
                    if (particle_colision_change == true) {
                        ChangeParticle(element);
                    } // Change Particle Size on colision
                }
                if (ver == rect_main.offsetWidth - element_width) {
                    d_h = "left";
                    ver = rect_main.offsetWidth - element_width;
                    isresting = 1;
                    if (particle_colision_change == true) {
                        ChangeParticle(element);
                    } // Change Particle Size on colision
                }
                if (ver <= 0) {
                    d_h = "right";
                    ver = 0;
                    isresting = 1;
                    if (particle_colision_change == true) {
                        ChangeParticle(element);
                    } // Change Particle Size on colision
                }

                // It won add another position until the end of transition
                if (isresting == 1) {
                    let RandomTransitionTime =
                        Math.floor(
                            Math.random() *
                                (max_transition_speed -
                                    min_transition_speed +
                                    1)
                        ) + min_transition_speed;
                    element.style.transitionDuration =
                        RandomTransitionTime + "ms";

                    // Check Position
                    if (d_v == "down" && d_h == "left") {
                        element.style.left =
                            Number(element.offsetLeft) - Number(300) + "px";
                        element.style.top =
                            rect_main.offsetHeight -
                            Number(element_width) +
                            "px";
                        isresting = 0;
                    }
                    if (d_v == "down" && d_h == "right") {
                        element.style.left =
                            Number(element.offsetLeft) + Number(300) + "px";
                        element.style.top =
                            rect_main.offsetHeight -
                            Number(element_width) +
                            "px";
                        isresting = 0;
                    }
                    if (d_v == "top" && d_h == "left") {
                        element.style.left =
                            Number(element.offsetLeft) -
                            Number(element_width) -
                            Number(300) +
                            "px";
                        element.style.top = "0px";
                        isresting = 0;
                    }
                    if (d_v == "top" && d_h == "right") {
                        element.style.left =
                            Number(element.offsetLeft) -
                            Number(element_width) +
                            Number(300) +
                            "px";
                        element.style.top = "0px";
                        isresting = 0;
                    }
                }

                // Saves particle position to array
                if (element.offsetLeft != 0 && element.offsetTop != 0) {
                    particle_x_ray[element.id] = {
                        "id": element.id,
                        "x": element.offsetLeft,
                        "y": element.offsetTop,
                    };
                }
            }

            // Call function for the first time
            SetFrame();
        };

        // Set up particles to selector div
        this.SetupParticles = function (number) {
            let resp_particles;
            particle_x_ray = [];

            // Get window viewport inner width
            let windowViewportWidth = window.innerWidth;

            // If functions brings no number, it follow the default
            if (number == undefined) {
                // Loop responsive object to get current viewport
                for (let loop = 0; loop < responsive.length; loop++) {
                    if (responsive[loop].breakpoint >= windowViewportWidth) {
                        resp_particles =
                            responsive[loop]["settings"].particle_number;
                    }
                }

                // If there is no result from above, default particles are applied
                if (resp_particles == undefined) {
                    resp_particles = this.particle_number;
                }
            } else {
                resp_particles = number;
            }

            // Add number of particles to selector div
            for (let i = 1; i <= resp_particles; i++) {
                // Generate random number to particles
                let random_id_particle =
                    Math.floor(Math.random() * (9999 - 0 + 1)) + 0;

                // Check if image source is empty and append particle to main div
                if (this.particle_image["image"] == false) {
                    document
                        .getElementById(this.selector)
                        .insertAdjacentHTML(
                            "beforeend",
                            "<div id='bvparticle_" +
                                random_id_particle +
                                "' class='bvambient_particle' style='display: block;'></div>"
                        );
                } else {
                    document
                        .getElementById(this.selector)
                        .insertAdjacentHTML(
                            "beforeend",
                            "<img src='" +
                                this.particle_image["src"] +
                                "' id='bvparticle_" +
                                random_id_particle +
                                "' class='bvambient_particle' style='display: block;'>"
                        );
                }

                let bvparticle = document.getElementById(
                    "bvparticle_" + random_id_particle
                );

                // Add
                particle_x_ray.push("bvparticle_" + random_id_particle);

                // Get Width and Height of main div
                let widthMainDiv = document.getElementById(selector);

                // Get random number based on the width and height of main div
                let RandomTopPosition = Math.floor(
                    Math.random() * window.innerHeight
                );

                let RandomLeftPosition = Math.floor(
                    Math.random() * window.innerWidth
                );

                // Get random number based on the width and height of main div
                let RandomWidth =
                    Math.random() *
                        (this.particle_maxwidth - this.particle_minwidth) +
                    this.particle_minwidth;

                // Get Random Opacity between 0.2 and 1 if active
                let RandomOpacity =
                    particle_opacity == true ? Math.random() : 1;

                // Add random positioning to particle
                bvparticle.style.top = RandomTopPosition + "px";
                bvparticle.style.left = RandomLeftPosition + "px";
                bvparticle.style.width = RandomWidth + "px";
                bvparticle.style.height = RandomWidth + "px";
                bvparticle.style.opacity = RandomOpacity;
                bvparticle.style.borderRadius = particle_radius + "px";

                // Check if it has random color enabled
                if (particle_background == "random") {
                    bvparticle.style.backgroundColor = getRandomColor();
                } else {
                    bvparticle.style.backgroundColor = particle_background;
                }

                // Move particle
                this.MoveParticle(bvparticle);
            }
        };

        // ** SETUP SLIDE **
        this.SetupParticles();

        if (refresh_onfocus == true) {
            // When user enters tab again refresh position
            document.addEventListener("focus", (e) => {
                document.getElementById(selector).innerHTML = "";
                this.SetupParticles();
            });
        }

        // Refresh results
        this.particle_x_ray = particle_x_ray;

        // Generates a random hex color
        function getRandomColor() {
            let letters = "0123456789ABCDEF";
            let color = "#";
            for (let i = 0; i < 6; i++) {
                color += letters[Math.floor(Math.random() * 16)];
            }
            return color;
        }
    }

    // ** METHODS **
    // REFRESH PARTICLES
    Refresh() {
        // Remove all particles
        document.getElementById(this.selector).innerHTML = "";
        // Setup new Ambient
        this.SetupParticles();
    }

    // DESTROY
    Destroy() {
        // Remove all particles and unbind all its events
        document.getElementById(this.selector).remove();
    }

    // ADD PARTICLES
    Add(number) {
        if (number != undefined) {
            // Add new particles
            this.SetupParticles(number);
        }
    }

    // PAUSE
    Controls(command) {
        // Check what type of command is
        switch (command) {
            case "pause": // Pause Particles moviment
                isPaused = true;
                break;
            case "play": // Resume Particles moviment
                isPaused = false;
                break;
            default:
                console.log("BVAmbient | Command not recognized.");
        }
    }

    // CHANGE PARTICLES
    Change(properties) {
        // Changes particles according to properties available
        if (properties.type == "particle_background") {
            document.querySelectorAll(".bvambient_particle").forEach((item) => {
                // Change to chosen color
                item.style.backgroundColor = properties.value;
            });
        } else {
            console.log("BVAmbient | Propertie not recognized.");
        }
    }
}
