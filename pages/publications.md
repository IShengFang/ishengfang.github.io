---
layout: page
title: "Publications"
permalink: /publications/
kicker: "Research"
lede: "Peer-reviewed papers, workshop presentations, awards, and project links."
description: "Publications by I-Sheng Fang in generative AI, computer vision, photography, depth estimation, stereo matching, and style transfer."
---

<div class="publication-toolbar" data-publication-switch>
  <button class="filter-button" type="button" data-publication-mode-button="selected">Selected</button>
  <button class="filter-button is-active" type="button" data-publication-mode-button="all">All Publications</button>
</div>

<div class="publication-list publication-list--page" data-publications data-publication-mode="all">
  {% for pub in site.data.publications %}
    {% include publication-card.html publication=pub %}
  {% endfor %}
</div>

<p class="note-text">For citation indexes and additional metadata, visit <a href="https://scholar.google.com/citations?user=zLeqqSwAAAAJ" target="_blank" rel="noopener noreferrer">Google Scholar</a>.</p>
