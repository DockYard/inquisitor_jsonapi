# Inquisitor JSONAPI [![Build Status](https://secure.travis-ci.org/DockYard/inquisitor_jsonapi.svg?branch=master)](http://travis-ci.org/DockYard/inquisitor_jsonapi)

Easily build composable queries for Ecto for JSON API endpoints using
[Inquisitor](https://github.com/dockyard/inquisitor)

**[Inquisitor JSONAPI is built and maintained by DockYard, contact us for expert Elixir and Phoenix consulting](https://dockyard.com/phoenix-consulting)**.

This plugin for [Inquisitor](https://github.com/dockyard/inquisitor)
aims to implement all of the relevant [Fetching
Data](http://jsonapi.org/format/#fetching) section for the [JSON API spec](http://jsonapi.org/)

[Make sure you reference Inquisitor's Usage section
first](https://github.com/DockYard/inquisitor#usage)

#### Progress

* - [x] [Include](http://jsonapi.org/format/#fetching-includes)
* - [ ] [Field](http://jsonapi.org/format/#fetching-sparse-fieldsets)
* - [x] [Sort](http://jsonapi.org/format/#fetching-sorting)
* [Page](http://jsonapi.org/format/#fetching-pagination)
  * - [x] `order,limit`
  * - [x] `number,size`
  * - [ ] `cursor`
* - [x] [Filter](http://jsonapi.org/format/#fetching-filtering)

## Include

JSON API Include (Ecto preload) Plugin

### Usage

Use `Inquisitor.JsonApi.Include` *after* `Inquisitor`

```elixir
defmodule MyApp.PostController do
  use MyAp.Web, :controller
  use Inquisitor
  use Inquisitor.JsonApi.Include

  ...
```

[This plugin follows the spec for sorting with JSON
API](http://jsonapi.org/format/#fetching-includes). All requests should
conform to that URL schema for this plugin to work.

`[GET] http://example.com/posts?include=tags,author`

Refer to the Docs for this module on how to enable preloading properly.

## Sort

JSON API Sorting Plugin

### Usage

Use `Inquisitor.JsonApi.Sort` *after* `Inquisitor`

```elixir
defmodule MyApp.PostController do
  use MyAp.Web, :controller
  use Inquisitor
  use Inquisitor.JsonApi.Sort

  ...
```

[This plugin follows the spec for sorting with JSON
API](http://jsonapi.org/format/#fetching-sorting). All requests should
conform to that URL schema for this plugin to work.

`[GET] http://example.com/posts?sort=-create,title`

The plugin with correct apply `ASC` and `DESC` sort order to the built
query.

## Page

JSON API Pagination Plugin

### Usage

Use `Inquisitor.JsonApi.Page` *after* `Inquisitor`

```elixir
defmodule MyApp.PostController do
  use MyAp.Web, :controller
  use Inquisitor
  use Inquisitor.JsonApi.Page

  ...
```

[This plugin follows the spec for pagination with JSON
API](http://jsonapi.org/format/#fetching-pagination). All requests should
conform to that URL schema for this plugin to work.

`[GET] http://example.com/posts?page[limit]=10&page[offset]=2`
`[GET] http://example.com/posts?page[size]=10&page[number]=2`

Cursor pagination is not yet implemented.

You may need to calculate certain page data to generate pagination
links. You can use `page_data/3` that this module `import`s for you.

```elixir
  query = build_query(User, conn, params)
  data = page_data(query, repo, params)

  links = build_links(data)
  meta = build_meta(data)
  users = Repo.all(query)
```

## Filter

JSON API Filtering Plugin

### Usage

Use `Inquisitor.JsonApi.Filter` *after* `Inquisitor`

```elixir
defmodule MyApp.PostController do
  use MyAp.Web, :controller
  use Inquisitor
  use Inquisitor.JsonApi.Filter

  ...
```

[This plugin follows the spec for pagination with JSON
API](http://jsonapi.org/format/#fetching-filtering). All requests should
conform to that URL schema for this plugin to work.

`[GET] http://example.com/posts?filter[name]=Brian&filter[age]=99`

By default `Filter` is no-op. You must define a custom
`build_filter_query/4` handler:

```elixir
def build_filter_query(query, "name", name, _conn) do
  Ecto.Query.where(query, [r], r.name == ^name)
end
```

## Authors

* [Brian Cardarella](http://twitter.com/bcardarella)

[We are very thankful for the many contributors](https://github.com/dockyard/inquisitor_jsonapi/graphs/contributors)

## Versioning

This library follows [Semantic Versioning](http://semver.org)

## Want to help?

Please do! We are always looking to improve this library. Please see our
[Contribution Guidelines](https://github.com/dockyard/inquisitor_jsonapi/blob/master/CONTRIBUTING.md)
on how to properly submit issues and pull requests.

## Legal

[DockYard](http://dockyard.com/), Inc. &copy; 2017

[@dockyard](http://twitter.com/dockyard)

[Licensed under the MIT license](http://www.opensource.org/licenses/mit-license.php)
