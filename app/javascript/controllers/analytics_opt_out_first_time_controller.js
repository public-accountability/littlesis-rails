document.addEventListener("DOMContentLoaded", () => {
  const railsEnv = document.querySelector('meta[name="rails-env"]')?.content;

  if (railsEnv === "test") {
    return;
  }

  const storageKey = "analytics_opt_out_shown";

  if (!localStorage.getItem(storageKey)) {
    const link = document.getElementById("analytics-opt-out-link");
    if (link) {
      link.click();
      localStorage.setItem(storageKey, "true");
    }
  }
});
