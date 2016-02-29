## <%= information[:endpoint_title] || ' ' %>

#### <%= request.method %> <%= request.path %>

<%= information[:about] %>

### Query Parameters
| Parameter | Value |
| --------- | ----- |
<%=
  table_entries = []
  request_params = request.params.except(:controller, :action, :format)
  request_params.each do |param, value|
    table_entries << "| #{param} | #{value} |"
  end

  table_entries << "| none | nil |" if table_entries.empty?
  table_entries.join("\n")
%>

### Response
**Status: <%= response.status %>**

**Response Headers**

| Field | Value |
| ----- | ----- |
<%=
table_entries = []
response.headers.each do |header, value|
  table_entries << "| #{header} | #{value} |"
end

table_entries << "| none | nil |" if table_entries.empty?
table_entries.join("\n")
%>

**JSON Example**
```json
<%= JSON.pretty_generate(JSON.parse(response.body)) %>
```

<%= information[:note] %>

=================================================================================
