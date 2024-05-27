// main script
(function () {
  "use strict";

  // Dropdown Menu Toggler For Mobile
  // ----------------------------------------
  const dropdownMenuToggler = document.querySelectorAll(
    ".nav-dropdown > .nav-link",
  );

  dropdownMenuToggler.forEach((toggler) => {
    toggler?.addEventListener("click", (e) => {
      e.target.closest('.nav-item').classList.toggle("active");
    });
  });

  // Testimonial Slider
  // ----------------------------------------
  new Swiper(".testimonial-slider", {
    spaceBetween: 24,
    loop: true,
    pagination: {
      el: ".testimonial-slider-pagination",
      type: "bullets",
      clickable: true,
    },
    breakpoints: {
      768: {
        slidesPerView: 2,
      },
      992: {
        slidesPerView: 3,
      },
    },
  });
})();

async function sha1(message) {
  // Convert the message string to a Uint8Array
  const msgBuffer = new TextEncoder().encode(message);

  // Hash the message
  const hashBuffer = await crypto.subtle.digest('SHA-1', msgBuffer);

  // Convert ArrayBuffer to Array
  const hashArray = Array.from(new Uint8Array(hashBuffer));

  // Convert bytes to hex string
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  return hashHex;
}


let button = document.getElementsByClassName('level-3');

if (button) {

  button[0].addEventListener('click', function (e) {
    e.preventDefault();
    let password = prompt("The password :");
    console.log(password)
    login(password)
  })

}


function login(secret) {
  sha1(secret).then(hash => {
    console.log("hash:", hash);
    var url = "/blog/" + hash // Assuming you meant to append '/index.html' to the URL

    var request = new XMLHttpRequest();
    request.open('GET', url, true);
    console.log("Good");
    request.onload = function () {
      if (request.status >= 200 && request.status < 400) {
        window.location = window.location.origin + url;
      } else {
        alert("Password Incorrect");
      }
    };
    request.send();
  }).catch(error => {
    console.error("Error hashing password:", error);
  });
}

