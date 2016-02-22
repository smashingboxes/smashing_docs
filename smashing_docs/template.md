#### <%= request.method %> <%= request.path %>

<%= information[:note] %>

| Param | Value |
| ----- | ----- |
<%= table_entries = []
  request.params.except(:controller, :action, :format).each do |param, value|
    table_entries << "| #{param} | #{value} |"
  end
  table_entries.join("\n") %>

Response: <%= response.status %>
```json
<%= JSON.pretty_generate(JSON.parse(response.body)) %>
```
