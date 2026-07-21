
# PRD: DISCO
**PM** | **Status** | **Date** | **Version** |
| :--- |  :--- | :--- | :--- |
|Chanmin Jeon | DRAFT | 2026-07-02 | v1.1 |

---

## 1. Overview
* **Product Vision:** DISCO is an AI-powered language assistant that translates user queries on-demand and automatically persists words and phrases into a personal vocabulary list.
* **Core Goal:** The product aims to deliver a seamless, frictionless language-learning experience integrated into users' daily workflows.

## 2. Problem Statement
* **The Status Quo:** Unlike structured exam preparation, casual and contextual language learning requires users to manually search, record, and review vocabulary.
* **The Friction:** Nowadays, many users leverage LLMs for translation. However, this process introduces high administrative friction—forcing users to manually copy and paste terms elsewhere and to wait for the generation process to complete.
* **The Solution:** DISCO eliminates this fragmented workflow by providing an intuitive search interface with an automated background-saving mechanism for seamless review.

## 3. Target Users
1. **International Students:** Expatriates and students who frequently need to look up contextual expressions in their daily lives.
2. **Autonomous Casual Learners:** Self-driven learners who absorb languages through immersion (media, articles) rather than structured vocabulary textbooks.
3. **Active Foreign-Language Readers:** Professionals or avid readers who encounter recurring unfamiliar terms while reading digital foreign-language texts.

## 4. Key Objectives
1. **Instant Lookup:** Enable instant, frictionless lookups for words and phrases, optimized for repetitive usage scenarios like reading.
2. **Retention Boost:** Boost user retention and vocabulary recall by offering diverse review mechanics based on the persisted data.

## 5. Functional Requirements

| ID | Component / Domain | Detailed Requirements | Priority |
| :--- | :--- | :--- | :--- |
| **F-01** | Multi-Theme Workspace | The main window features multiple chat sessions partitioned by different language themes. Each chat has a split-screen layout with an embedded vocabulary list on the sidebar. | **P0** |
| **F-02** | Automated Background Saving | Only words and phrases are saved automatically to the active database. | **P0** |
| **F-03** | System-Wide Global Shortcut | Whenever the user presses a user-configurable shortcut key, a lightweight utility pop-up window instantly appears to process translation requests. | **P0** |
| **F-04** | Dual-Engine Translation | There are two options for sending user queries: The Google Translation API and the Gemini API. User can choose either one depending on their needs. | **P0** |
| **F-05** | Multi-Modal Review System | Provides diverse ways for reviewing the auto-saved list. Users can select options directly from the list, including displaying items as Flash Cards or generating a vocabulary PDF file. | **P1** |