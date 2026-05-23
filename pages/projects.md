---
layout: page
title: "Projects"
permalink: /projects/
kicker: "Projects"
lede: "Creative AI exhibitions, research collections, typography experiments, and open source projects."
description: "Projects by I-Sheng Fang, including creative AI exhibitions, typography research, generative AI for photography, and open source work."
---

<div class="filter-bar" data-filter-group aria-label="Project filters">
  <button class="filter-button is-active" type="button" data-filter="all">All</button>
  <button class="filter-button" type="button" data-filter="creative-ai">Creative AI</button>
  <button class="filter-button" type="button" data-filter="research-collection">Research Collections</button>
  <button class="filter-button" type="button" data-filter="research-project">Research Projects</button>
  <button class="filter-button" type="button" data-filter="open-source">Open Source</button>
</div>

<div class="project-list project-list--page" data-filter-items>
  {% for project in site.data.projects %}
    {% include project-card.html project=project media_mode="image" %}
  {% endfor %}
</div>
