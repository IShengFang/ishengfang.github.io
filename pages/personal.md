---
layout: page
title: "Personal"
permalink: /personal/
kicker: "Beyond research"
lede: "My work is technical, but my eye is shaped by cameras, letterforms, airports, ballparks, and ordinary light."
description: "Personal interests of I-Sheng Fang, including film photography, typography, fantasy baseball, strength training, and aviation."
---

<section class="personal-page-intro" aria-labelledby="personal-page-intro-title">
  <div>
    <h2 id="personal-page-intro-title">Outside the Lab, Staring, Collecting, Feeling</h2>
    <p>{{ site.data.photography.summary }}</p>
    <ul class="tag-list tag-list--large interest-strip" aria-label="Personal interests">
      {% for interest in site.data.interests %}
        <li>{{ interest.short_title }}</li>
      {% endfor %}
    </ul>
  </div>
  <div class="instagram-preview" aria-label="Instagram photography preview">
    <div class="instagram-preview__header">
      <span>{{ site.data.photography.handle }}</span>
      <a href="{{ site.data.photography.url }}" target="_blank" rel="noopener noreferrer">Instagram</a>
    </div>
    <div class="instagram-grid">
      {% for photo in site.data.photography.photos %}
        {% assign photo_href = photo.href | default: site.data.photography.url %}
        <a class="instagram-photo" href="{{ photo_href }}" target="_blank" rel="noopener noreferrer" aria-label="Open Instagram post from {{ photo.posted | default: site.data.photography.handle }}">
          <img src="{{ photo.src | relative_url }}" alt="{{ photo.alt }}" loading="lazy" width="150" height="150">
        </a>
      {% endfor %}
    </div>
  </div>
</section>

<section class="baseball-section" aria-labelledby="baseball-title">
  <div class="baseball-copy">
    <p class="eyebrow">⚾ Fantasy Baseball</p>
    <h2 id="baseball-title">I play fantasy baseball.</h2>
  </div>
  <div class="baseball-showcase" aria-label="Fantasy baseball results">
    <figure class="baseball-result baseball-result--champion">
      <div class="baseball-result__image-frame">
        <img src="{{ '/assets/img/baseball/trophy_first.svg' | relative_url }}" alt="2025 fantasy baseball league champion trophy" loading="lazy" width="200" height="200">
      </div>
      <figcaption><span>2025</span> League Champion</figcaption>
    </figure>
    <figure class="baseball-result">
      <div class="baseball-result__image-frame">
        <img src="{{ '/assets/img/baseball/trophy_third.svg' | relative_url }}" alt="2024 fantasy baseball third-place trophy" loading="lazy" width="150" height="150">
      </div>
      <figcaption><span>2024</span> Third Place</figcaption>
    </figure>
  </div>
</section>

<section class="flight-log-section" aria-labelledby="flight-log-title">
  <div class="flight-log-heading">
    <p class="eyebrow"> ✈️ Aviation</p>
    <h2 id="flight-log-title">myFlightradar24</h2>
    <p>My flight logbook on Flightradar24.</p>
  </div>
  <div class="flight-log-embed">
    <iframe
      src="https://my.flightradar24.com/ishengfang"
      title="I-Sheng Fang myFlightradar24 profile"
      loading="lazy"
      width="100%"
      height="760"></iframe>
  </div>
  <p class="flight-log-fallback">
    <a href="https://my.flightradar24.com/ishengfang" target="_blank" rel="noopener noreferrer">Open myFlightradar24 profile</a>
  </p>
</section>
