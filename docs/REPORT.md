1 # introduction

Al comenzar este proyecto, mi primera sensación entusiasmo por que sabia que no era solo una app, sino una oportunidad para demostrar criterio tecnica
orden y capacidad de entrega, vengo construyendo apps en Flutter de forma constante, pero esto me obligo mas a cuidar la arquitectura, el
detalle y la consistencia de experiencia de usuario

2 # Learning Journey

During the development process, I reinforced and learned in depth several points that I previously only partially understood.

- Architecture and separation of responsibilities (Clean Architecture / layers) = I organized the code to avoid logic in widgets
  and facilitate testing and maintenance

- State management and reactive UI = an approach to keeping screens clean, avoiding instantiated services within build()
  and moving logic to dedicated controllers/classes

- Navigation and route structure = I prioritized clear, consistent, and scalable routes for new screens

3 # Challenges Faced

Visual consistency across screens = Initially, the home and HBB sections weren't the same; I struggled with that a bit. However, due
to time constraints, the save system's aesthetics weren't updated.

Other projects are consuming my Firebase credits, so I started applying for base64, but since they specifically asked for storage, I
had to migrate.torage problem =

4 # Reflection and Future Directions

This project taught me two important lessons

1 = Technical: a clean architecture + reusable components makes adding features (new categories, screens, cards) much faster and safer
2 = Professionally, I learned to better document decisions, prioritize consistency, and consider what an evaluator reviews
3 = Reorder saved

5 # Feature 1 — HBB Section

Purpose: To incorporate an additional category with its own identity and consistent layout (hero + grid) to separate editorial content from user-generated content.

Full Article Read Screen

Purpose: To address the issue of lengthy articles by enabling full-page reading with scrolling (API needs to be added)

Visual Consistency

Purpose: To unify aesthetics and visual hierarchy so the entire app feels coherent

6 # How can you improve this?

- Add more automated demos
- Add basic “offline-first” (cache) and more polished loading placeholders
- Extend the theme system (typography/spacing)

#6.1 Prototypes Created

Prototype — Translation system: base implementation (structure + keys + language change) used as a test and then applied to real screens
Prototype — Reusable visual components: cards/surface (hero/grid) as an “aesthetic base” to then standardize the design

I created the HBB category as a separate, modular display, reusing the “hero + grid” pattern

Related files

room/daily_news_hbb.dart

room/daily_news_hbb_category_button.part.dart

room/daily_news_hbb_content.part.dart

room/daily_news_hbb_details_page.part.dart

room/daily_news_hbb_model.part.dart


To achieve visual consistency between hero/grid and feed posts, I implemented a reusable “surface” with card variants and separate pieces to compose layouts uniformly

Related files

room/cards/card_surface.part.dart

room/cards/post_card_variants.part.dart

room/cards/post_cards.part.dart

room/cards/post_image.part.dart

room/cards/post_text_block.part.dart

room/cards/post_date.part.dart

room/cards/post_details.part.dart


7 # Extra Sections

Architecture Notes
- Structure by features
- Reusable UI components for cards and surfaces
- Logic outside of build() to keep widgets small and maintainable
- Total development time: [17]
- Critical bugs resolved: [Bad news from API]




