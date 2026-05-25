---
layout: default
body_class: "home"
description: "I-Sheng Fang is a computer vision and generative AI researcher working on photography, depth estimation, style transfer, typography, and creative AI applications."
image: "/assets/img/profile/profile-og.jpg"
---

<section class="hero" aria-labelledby="hero-title">
  <div class="container hero__grid">
    <div class="hero__content">
      <p class="eyebrow">{{ site.data.profile.role }}</p>
      <h1 id="hero-title">I-Sheng Fang</h1>
      <p class="hero__names">Ethan Fang / 方 宜晟 / Gî-Tshiânn Png</p>
      <p class="hero__pronunciation">{{ site.data.profile.pronunciation }}</p>
      <p class="hero__summary">{{ site.data.profile.hero_summary }}</p>
      <ul class="hero__links social-links" aria-label="Hero contact and profile links">
        {% for email in site.data.links.emails %}
          <li>
            <a href="{{ email.href }}" aria-label="Email {{ email.label }} at {{ email.value }}">
              {{ email.button_label | default: email.value }}
            </a>
          </li>
        {% endfor %}
        {% for link in site.data.links.primary %}
          {% unless link.kind == "email" %}
            <li>
              <a href="{% if link.href contains '://' or link.href contains 'mailto:' %}{{ link.href }}{% else %}{{ link.href | relative_url }}{% endif %}" {% if link.href contains '://' %}target="_blank" rel="noopener noreferrer"{% endif %}>
                {{ link.label }}
              </a>
            </li>
          {% endunless %}
        {% endfor %}
        {% for link in site.data.links.profiles %}
          <li>
            <a href="{% if link.href contains '://' or link.href contains 'mailto:' %}{{ link.href }}{% else %}{{ link.href | relative_url }}{% endif %}" {% if link.href contains '://' %}target="_blank" rel="noopener noreferrer"{% endif %}>
              {{ link.label }}
            </a>
          </li>
        {% endfor %}
      </ul>
    </div>
    <figure class="hero__portrait">
      <img src="{{ '/assets/img/profile/profile.jpg' | relative_url }}" alt="Portrait of I-Sheng Fang" width="900" height="1200">
    </figure>
  </div>
</section>


<section class="section section--muted section--news" aria-labelledby="news">
  <div class="container">
    {% include section-heading.html id="news" kicker="News" title="Recent Updates" %}
    <div class="news-list">
      {% for item in site.data.news %}
        <article class="news-item">
          <time>{{ item.date }}</time>
          <div>
            <h3>{{ item.title }}</h3>
            {% if item.links %}
              <ul class="link-list">
                {% for link in item.links %}
                  <li><a href="{{ link.href }}" target="_blank" rel="noopener noreferrer">{{ link.label }}</a></li>
                {% endfor %}
              </ul>
            {% endif %}
          </div>
        </article>
      {% endfor %}
    </div>
  </div>
</section>

<section class="section section--intro" aria-labelledby="about">
  <div class="container intro-grid">
    <div>
      {% include section-heading.html id="about" kicker="About" title="Researcher working where vision models meet creative tools" %}
      {% for paragraph in site.data.profile.short_bio %}
        <p>{{ paragraph }}</p>
      {% endfor %}
    </div>
    <aside class="profile-panel" aria-label="Research interests">
      <h2>Research Interests</h2>
      <ul class="tag-list tag-list--large">
        {% for interest in site.data.profile.interests %}
          <li>{{ interest }}</li>
        {% endfor %}
      </ul>
    </aside>
  </div>
</section>

<section class="section" aria-labelledby="selected-publications">
  <div class="container">
    {% include section-heading.html id="selected-publications" kicker="Publications" title="Selected Publications" lede="Peer-reviewed and workshop work in generative modeling, camera-aware synthesis, depth sensing, stereo matching, and style transfer." %}
    <div class="publication-toolbar" data-publication-switch>
      <button class="filter-button is-active" type="button" data-publication-mode-button="selected">Selected</button>
      <button class="filter-button" type="button" data-publication-mode-button="all">All Publications</button>
    </div>
    <div class="publication-list" data-publications data-publication-mode="selected">
      {% for pub in site.data.publications %}
        {% include publication-card.html publication=pub %}
      {% endfor %}
    </div>
    <p class="section-link"><a href="{{ '/publications/' | relative_url }}">View complete publication list</a></p>
  </div>
</section>

<section class="section section--muted" aria-labelledby="selected-projects">
  <div class="container">
    {% include section-heading.html id="selected-projects" kicker="Projects" title="Creative, Research, and Open Source Work" %}
    <div class="project-list">
      {% for project in site.data.projects %}
        {% if project.featured %}
          {% include project-card.html project=project media_mode="video" %}
        {% endif %}
      {% endfor %}
    </div>
    <p class="section-link"><a href="{{ '/projects/' | relative_url }}">Browse all projects</a></p>
  </div>
</section>

<section class="section" aria-labelledby="experience">
  <div class="container timeline-grid">
    <div>
      {% include section-heading.html id="experience" kicker="Experience" title="Experience Snapshot" %}
      <div class="timeline-list">
        {% assign featured_experience = site.data.experience | where: "featured", true %}
        {% for item in featured_experience %}
          <article class="timeline-item">
            <p class="timeline-item__date">{{ item.date }}</p>
            <h3>{{ item.title }}</h3>
            <p class="timeline-item__org">{{ item.organization }}</p>
            <p>{{ item.summary }}</p>
          </article>
        {% endfor %}
      </div>
    </div>
    <div>
      {% include section-heading.html id="service" kicker="Service" title="Reviewing and Organizing" %}
      <div class="timeline-list">
        {% for item in site.data.service %}
          <article class="timeline-item">
            <p class="timeline-item__date">{{ item.type }} / {{ item.date }}</p>
            <h3>{{ item.title }}</h3>
            <p>{{ item.summary }}</p>
            {% if item.links %}
              <ul class="link-list">
                {% for link in item.links %}
                  <li><a href="{{ link.href }}" target="_blank" rel="noopener noreferrer">{{ link.label }}</a></li>
                {% endfor %}
              </ul>
            {% endif %}
          </article>
        {% endfor %}
      </div>
    </div>
  </div>
</section>

<section class="section section--personal" aria-labelledby="personal">
  <div class="container personal-grid">
    <div class="personal-copy">
      {% include section-heading.html id="personal" kicker="Personal" title="Outside the Lab" %}
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
  </div>
</section>

<section class="section section--contact" id="contact" aria-labelledby="contact-heading">
  <div class="container contact-grid">
    <div class="contact-copy">
      <p class="eyebrow">Contact</p>
    <h2 id="contact-heading">Open to research conversations, collaboration, and consulting.</h2>
    </div>
    <div>
      <ul class="contact-email-list" aria-label="Email addresses">
        {% for email in site.data.links.emails %}
          <li>
            <a class="contact-email-button" href="{{ email.href }}">
              <span>{{ email.label }}</span>
              <strong>{{ email.value }}</strong>
            </a>
          </li>
        {% endfor %}
      </ul>
      <ul class="social-links" aria-label="Primary profile links">
        {% for link in site.data.links.primary %}
          {% unless link.kind == "email" %}
            <li>
              <a href="{{ link.href }}" {% unless link.href contains 'mailto:' %}target="_blank" rel="noopener noreferrer"{% endunless %}>
                {{ link.label }}
              </a>
            </li>
          {% endunless %}
        {% endfor %}
      </ul>
      <ul class="social-links social-links--secondary">
        {% for link in site.data.links.profiles %}
          <li><a href="{{ link.href }}" target="_blank" rel="noopener noreferrer">{{ link.label }}</a></li>
        {% endfor %}
      </ul>
    </div>
  </div>
</section>
