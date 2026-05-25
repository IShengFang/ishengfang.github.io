(function () {
  var root = document.documentElement;
  var toggle = document.querySelector("[data-theme-toggle]");
  var storedTheme = null;

  function setTheme(theme) {
    if (theme === "dark") {
      root.setAttribute("data-theme", "dark");
      if (toggle) {
        toggle.setAttribute("aria-label", "Switch to light theme");
        toggle.setAttribute("title", "Switch to light theme");
      }
      return;
    }

    root.setAttribute("data-theme", "light");
    if (toggle) {
      toggle.setAttribute("aria-label", "Switch to dark theme");
      toggle.setAttribute("title", "Switch to dark theme");
    }
  }

  try {
    storedTheme = window.localStorage.getItem("theme");
  } catch (error) {
    storedTheme = null;
  }

  if (storedTheme === "dark" || storedTheme === "light") {
    setTheme(storedTheme);
  } else {
    setTheme("light");
  }

  if (toggle) {
    toggle.addEventListener("click", function () {
      var nextTheme = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
      setTheme(nextTheme);
      try {
        window.localStorage.setItem("theme", nextTheme);
      } catch (error) {
        return;
      }
    });
  }

  var siteHeader = document.querySelector("[data-site-header]");
  var navToggle = document.querySelector("[data-nav-toggle]");
  var siteNav = document.querySelector("[data-site-nav]");

  function setNavigationOpen(isOpen) {
    if (!siteHeader || !navToggle) {
      return;
    }

    siteHeader.classList.toggle("is-nav-open", isOpen);
    navToggle.setAttribute("aria-expanded", isOpen ? "true" : "false");
    navToggle.setAttribute("aria-label", isOpen ? "Close navigation" : "Open navigation");
    navToggle.setAttribute("title", isOpen ? "Close navigation" : "Open navigation");
  }

  if (siteHeader && navToggle && siteNav) {
    var wideNavigation = window.matchMedia ? window.matchMedia("(min-width: 641px)") : null;

    siteHeader.classList.add("is-nav-ready");

    navToggle.addEventListener("click", function () {
      setNavigationOpen(!siteHeader.classList.contains("is-nav-open"));
    });

    Array.prototype.slice.call(siteNav.querySelectorAll("a")).forEach(function (link) {
      link.addEventListener("click", function () {
        setNavigationOpen(false);
      });
    });

    document.addEventListener("click", function (event) {
      if (!siteHeader.contains(event.target)) {
        setNavigationOpen(false);
      }
    });

    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape") {
        setNavigationOpen(false);
      }
    });

    if (wideNavigation) {
      var closeNavigationOnWideScreens = function (event) {
        if (event.matches) {
          setNavigationOpen(false);
        }
      };

      closeNavigationOnWideScreens(wideNavigation);
      if (wideNavigation.addEventListener) {
        wideNavigation.addEventListener("change", closeNavigationOnWideScreens);
      } else if (wideNavigation.addListener) {
        wideNavigation.addListener(closeNavigationOnWideScreens);
      }
    }
  }

  var filterGroup = document.querySelector("[data-filter-group]");
  var filterItems = document.querySelector("[data-filter-items]");

  if (filterGroup && filterItems) {
    var buttons = Array.prototype.slice.call(filterGroup.querySelectorAll("[data-filter]"));
    var cards = Array.prototype.slice.call(filterItems.querySelectorAll("[data-category]"));

    buttons.forEach(function (button) {
      button.addEventListener("click", function () {
        var filter = button.getAttribute("data-filter");
        buttons.forEach(function (item) {
          item.classList.toggle("is-active", item === button);
        });
        cards.forEach(function (card) {
          var isVisible = filter === "all" || card.getAttribute("data-category") === filter;
          card.classList.toggle("is-hidden", !isVisible);
        });
      });
    });
  }

  var publicationGroups = Array.prototype.slice.call(document.querySelectorAll("[data-publications]"));
  var publicationSwitches = Array.prototype.slice.call(document.querySelectorAll("[data-publication-switch]"));

  function setPublicationMode(container, mode) {
    var scopedMode = mode === "selected" ? "selected" : "all";
    container.setAttribute("data-publication-mode", scopedMode);

    var switcher = container.previousElementSibling;
    if (!switcher || !switcher.matches("[data-publication-switch]")) {
      return;
    }

    Array.prototype.slice.call(switcher.querySelectorAll("[data-publication-mode-button]")).forEach(function (button) {
      button.classList.toggle("is-active", button.getAttribute("data-publication-mode-button") === scopedMode);
    });
  }

  publicationSwitches.forEach(function (switcher) {
    var container = switcher.nextElementSibling;
    if (!container || !container.matches("[data-publications]")) {
      return;
    }

    Array.prototype.slice.call(switcher.querySelectorAll("[data-publication-mode-button]")).forEach(function (button) {
      button.addEventListener("click", function () {
        setPublicationMode(container, button.getAttribute("data-publication-mode-button"));
      });
    });
  });

  publicationGroups.forEach(function (container) {
    setPublicationMode(container, container.getAttribute("data-publication-mode"));
  });
})();
