# Page Modules

Page modules provide a structured, reusable way to organize your web automation tests. Instead of scattering element locators throughout your test code, page modules encapsulate page structure in dedicated modules that can be reused across multiple tests.

Without page modules, tests require inline locators and element definitions, making them verbose and harder to maintain:

```gleam
let assert Ok(output) =
  driver.new(browser.Firefox)
  |> driver.goto("https://gleam.run/")
  |> get.node(by.xpath(
    "//div[@class='hero']//a[@href='https://tour.gleam.run/']",
  ))
  |> node.do(action.click(key.LeftClick))
  |> get.node(by.css("pre.log"))
  |> node.get(node.text())
  |> driver.close()
```

With page modules, the same test becomes more readable and the locators can be reused:

```gleam
let assert Ok(output) =
  driver.new(browser.Firefox)
  |> driver.goto("https://gleam.run/")
  |> gleam_page.tour_button(action.click(key.LeftClick))
  |> gleam_page.log_output(node.text())
  |> driver.close()
```

## Creating a Page Module

A page module is a regular Gleam module that defines functions for each element on a page. Each function takes a `WebDriver` and an action, then performs that action on the element.

### Basic Structure

```gleam
import butterbee/by
import butterbee/driver
import butterbee/page_module/element
import butterbee/webdriver.{type WebDriver}

// Navigate to the page
pub fn goto(driver: WebDriver(state)) {
  driver.goto(driver, "https://example.com/login")
}

// Define page elements
pub fn username_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("input#username"))
  |> element.perform_action(driver, action)
}

pub fn password_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("input#password"))
  |> element.perform_action(driver, action)
}

pub fn login_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("button[type='submit']"))
  |> element.perform_action(driver, action)
}
```

Then use the page module in your test:

```gleam
import login_page

pub fn login_test() {
  let assert Ok(_) =
    driver.new(Firefox)
    |> login_page.goto()
    |> login_page.username_field(node.set_value("testuser"))
    |> login_page.password_field(node.set_value("password123"))
    |> login_page.login_button(action.click(key.LeftClick))
    |> driver.close()
}
```

## Element Types

Page modules support different element types for common HTML structures:

### Basic Elements

Use `element` for standard HTML elements like inputs, buttons, links, and divs:

```gleam
import butterbee/page_module/element

pub fn submit_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("button#submit"))
  |> element.perform_action(driver, action)
}
```

### Select Elements (Dropdowns)

**Example Select element:**

<select id="pokemon" style="background-color: #202431; color: #d19a66; padding: 4px; border: 1px solid #b1a894;">
  <option value="pikachu">Pikachu</option>
  <option value="charmander">Charmander</option>
  <option value="bulbasaur">Bulbasaur</option>
  <option value="squirtle">Squirtle</option>
</select>

Use `select_element` for `<select>` dropdowns with specialized actions:

```gleam
import butterbee/page_module/select_element

pub fn pokemon_dropdown(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  select_element.define(field: by.css("select#pokemon"))
  |> select_element.perform_action(driver, action)
}
```

Then perform actions on the dropdown in your test:

```gleam
// Select an option by its visible text
driver
|> form_page.pokemon_dropdown(select_element.option("Charmander"))

// Get the currently selected option's text
driver
|> form_page.pokemon_dropdown(select_element.selected_text())
```

### Table Elements

**Example Table element:**
<table id="pokedex" style="color: #d19a66; border-collapse: collapse; border: 1px solid #b1a894;">
  <tr>
    <th style="border: 1px solid #b1a894; padding: 8px;">ID</th>
    <th style="border: 1px solid #b1a894; padding: 8px;">Name</th>
    <th style="border: 1px solid #b1a894; padding: 8px;">Type</th>
  </tr>
  <tr style="background-color: #1c1f2b;">
    <td style="border: 1px solid #b1a894; padding: 8px;">25</td>
    <td style="border: 1px solid #b1a894; padding: 8px;">Pikachu</td>
    <td style="border: 1px solid #b1a894; padding: 8px;">Electric</td>
  </tr>
  <tr style="background-color: #202431;">
    <td style="border: 1px solid #b1a894; padding: 8px;">4</td>
    <td style="border: 1px solid #b1a894; padding: 8px;">Charmander</td>
    <td style="border: 1px solid #b1a894; padding: 8px;">Fire</td>
  </tr>
  <tr style="background-color: #1c1f2b;">
    <td style="border: 1px solid #b1a894; padding: 8px;">573</td>
    <td style="border: 1px solid #b1a894; padding: 8px;">Cinccino</td>
    <td style="border: 1px solid #b1a894; padding: 8px;">Normal</td>
  </tr>
</table>

Use `table_element` to work with HTML tables, accessing the entire table, specific rows, or individual cells:

```gleam
import butterbee/page_module/table_element.{type NodeTable}

pub fn pokedex_table(
  driver: WebDriver(state),
  on_element: NodeTable,
  action: fn(_) -> WebDriver(new_state),
) {
  table_element.define(
    table: by.css("table#pokedex"),
    table_row: by.css("tr"),
    table_cell: by.css("td"),
    table_width: 3,
  )
  |> table_element.perform_action(driver, on_element, action)
}
```

Then perform actions on the table in your test

```gleam
// Get entire table text
let assert Ok(table_text) =
  driver
  |> pokedex_page.pokedex_table(table_element.Table, node.inner_text())
  |> driver.value()

// Get text from row 1 (0-indexed, so this is the second row)
let assert Ok(row_text) =
  driver
  |> pokedex_page.pokedex_table(table_element.Row(1), node.inner_text())
  |> driver.value()
// Result: "25\tPikachu\tElectric"

// Get text from cell at row 1, column 1
let assert Ok(cell_text) =
  driver
  |> pokedex_page.pokedex_table(table_element.Cell(1, 1), node.inner_text())
  |> driver.value()
// Result: "Pikachu"
```

**Note:** When defining a table element, you must specify the `table_width` (number of columns) to correctly calculate cell positions.

### List Elements

**Example List element:**
<ul id="team" style="border: 1px solid #b1a894; list-style-position: inside;">
  <li style="padding: 4px;">Pikachu</li>
  <li style="padding: 4px;">Charmander</li>
  <li style="padding: 4px;">Bulbasaur</li>
  <li style="padding: 4px;">Squirtle</li>
  <li style="padding: 4px;">Jigglypuff</li>
</ul>

Use `list_element` for ordered or unordered lists:

```gleam
import butterbee/page_module/list_element.{type NodeList}

pub fn team_list(
  driver: WebDriver(state),
  on_element: NodeList,
  action: fn(_) -> WebDriver(new_state),
) {
  list_element.define(
    list: by.css("ul#team"),
    list_item: by.css("li"),
  )
  |> list_element.perform_action(driver, on_element, action)
}
```

Then perform actions on the list in your test:

```gleam
// Get entire list text
let assert Ok(list_text) =
  driver
  |> team_page.team_list(list_element.List, node.inner_text())
  |> driver.value()
// Result: "Pikachu\nCharmander\nBulbasaur\nSquirtle\nJigglypuff"

// Get text from the second item (0-indexed)
let assert Ok(item_text) =
  driver
  |> team_page.team_list(list_element.Row(1), node.inner_text())
  |> driver.value()
// Result: "Charmander"

// Click the third item
driver
|> team_page.team_list(list_element.Row(2), action.click(key.LeftClick))
