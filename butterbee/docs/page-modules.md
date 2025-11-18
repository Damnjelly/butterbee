# Page Modules

Page modules provide a structured, reusable way to organize your web automation tests. Instead of scattering element locators throughout your test code, page modules encapsulate page structure in dedicated modules that can be reused across multiple tests.

Without page modules, tests require inline locators and element definitions, making them verbose and harder to maintain:

```gleam
use driver <- butterbee.run([Firefox])
let assert Ok(output) =
  driver
  |> butterbee.goto("https://gleam.run/")
  |> get.node(by.xpath(
    "//div[@class='hero']//a[@href='https://tour.gleam.run/']",
  ))
  |> node.do(action.click(key.LeftClick))
  |> get.node(by.css("pre.log"))
  |> node.get(node.text())
  |> butterbee.close()
```

With page modules, the same test becomes more readable and the locators can be reused:

```gleam
use driver <- butterbee.run([Firefox])
let assert Ok(output) =
  driver
  |> gleam_page.goto()
  |> gleam_page.tour_button(action.click(key.LeftClick))
  |> gleam_page.log_output(node.text())
  |> butterbee.close()
```

## Creating a Page Module

A page module is a regular Gleam module that defines functions for each element on a page. Each function takes a `WebDriver` and an action, then performs that action on the element.

### Basic Structure

```gleam
// Navigate to the page
pub fn goto(driver: WebDriver(state)) {
  butterbee.goto(driver, "https://example.com/login")
}

// Define page elements
pub fn username_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("input#username"))
  |> element.perform(driver, action)
}

pub fn password_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("input#password"))
  |> element.perform(driver, action)
}

pub fn login_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("button[type='submit']"))
  |> element.perform(driver, action)
}
```

Then use the page module in your test:

```gleam
import login_page

pub fn login_test() {
  let assert Ok(_) =
    driver
    |> login_page.goto()
    |> login_page.username_field(node.set_value("testuser"))
    |> login_page.password_field(node.set_value("password123"))
    |> login_page.login_button(action.click(key.LeftClick))
    |> butterbee.close()
}
```

## Element Types

Page modules support different element types for common HTML structures:

### Basic Elements

Use `element.define` for standard HTML elements like inputs, buttons, links, and divs:

```gleam
import butterbee/element

pub fn submit_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("button#submit"))
  |> element.perform(driver, action)
}
```

### Select Elements (Dropdowns)

**Example Select element:**

<select id="pokemon" style="background-color: var(--background-color); color: var(--text-color); border: 1px solid var(--text-color); border-radius: 4px; padding: 8px;">
  <option value="pikachu">Pikachu</option>
  <option value="charmander">Charmander</option>
  <option value="bulbasaur">Bulbasaur</option>
  <option value="squirtle">Squirtle</option>
</select>

Use normal `element.define` definitions for `<select>` dropdowns:

```gleam
import butterbee/element

pub fn pokemon_dropdown(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("select#pokemon"))
  |> element.perform(driver, action)
}
```


Then perform actions on the dropdown in your test. `node.select_option` and `node.selected_text` 
are specialized actions for `<select>` elements:

```gleam
// Select an option by its visible text
driver
|> form_page.pokemon_dropdown(node.select_option("Charmander"))

// Get the currently selected option's text
driver
|> form_page.pokemon_dropdown(node.selected_text())
```

### Table Elements

**Example Table element:**
<table id="pokedex" style="border-collapse: collapse; border: 1px solid var(--text-color);">
  <tr>
    <th style="color: var(--pink);border: 1px solid; padding: 8px;">ID</th>
    <th style="color: var(--pink);border: 1px solid; padding: 8px;">Name</th>
    <th style="color: var(--pink);border: 1px solid; padding: 8px;">Type</th>
  </tr>
  <tr style="background-color: var(--bg);">
    <td style="border: 1px solid; padding: 8px;">25</td>
    <td style="border: 1px solid; padding: 8px;">Pikachu</td>
    <td style="border: 1px solid; padding: 8px;">Electric</td>
  </tr>
  <tr style="background-color: var(--bg-shade-1);">
    <td style="border: 1px solid; padding: 8px;">4</td>
    <td style="border: 1px solid; padding: 8px;">Charmander</td>
    <td style="border: 1px solid; padding: 8px;">Fire</td>
  </tr>
  <tr style="background-color: var(--bg);">
    <td style="border: 1px solid; padding: 8px;">573</td>
    <td style="border: 1px solid; padding: 8px;">Cinccino</td>
    <td style="border: 1px solid; padding: 8px;">Normal</td>
  </tr>
</table>

Use `define_table` to work with HTML tables, accessing the entire table, specific rows, or individual cells:

```gleam
import butterbee/element

pub fn pokedex_table(
  driver: WebDriver(state),
  on_element: element.NodeTable,
  action: fn(_) -> WebDriver(new_state),
) {
  element.define_table(
    table: by.css("table#pokedex"),
    table_row: by.css("tr"),
    table_cell: by.css("td"),
    table_width: 3,
  )
  |> element.perform_on_table(driver, on_element, action)
}
```

Then perform actions on the table in your test

```gleam
// Get entire table text
let assert Ok(table_text) =
  driver
  |> pokedex_page.pokedex_table(element.Table, node.inner_text())
  |> butterbee.value()

// Get text from row 1 (0-indexed, so this is the second row)
let assert Ok(row_text) =
  driver
  |> pokedex_page.pokedex_table(element.Row(1), node.inner_text())
  |> butterbee.value()
// Result: "25\tPikachu\tElectric"

// Get text from cell at row 1, column 1
let assert Ok(cell_text) =
  driver
  |> pokedex_page.pokedex_table(element.Cell(1, 1), node.inner_text())
  |> butterbee.value()
// Result: "Pikachu"
```

### List Elements

**Example List element:**
<ul id="team" style="border: 1px solid; list-style-position: inside;">
  <li style="padding: 4px;">Pikachu</li>
  <li style="padding: 4px;">Charmander</li>
  <li style="padding: 4px;">Bulbasaur</li>
  <li style="padding: 4px;">Squirtle</li>
  <li style="padding: 4px;">Jigglypuff</li>
</ul>

Use `element.define_list` for ordered and unordered lists:

```gleam
import butterbee/element

pub fn team_list(
  driver: WebDriver(state),
  on_element: element.NodeList,
  action: fn(_) -> WebDriver(new_state),
) {
  element.define_list(
    list: by.css("ul#team"),
    list_item: by.css("li"),
  )
  |> element.perform_on_list(driver, on_element, action)
}
```

Then perform actions on the list in your test:

```gleam
// Get entire list text
let assert Ok(list_text) =
  driver
  |> team_page.team_list(element.List, node.inner_text())
  |> butterbee.value()
// Result: "Pikachu\nCharmander\nBulbasaur\nSquirtle\nJigglypuff"

// Get text from the second item (0-indexed)
let assert Ok(item_text) =
  driver
  |> team_page.team_list(element.Row(1), node.inner_text())
  |> butterbee.value()
// Result: "Charmander"

// Click the third item
driver
|> team_page.team_list(element.Row(2), action.click(key.LeftClick))
