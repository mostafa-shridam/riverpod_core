/// What the mock source answers, switchable at runtime so every data state of
/// the list page can be shown without a backend.
enum MockScenario { success, empty, error, offline, slow, partial }
