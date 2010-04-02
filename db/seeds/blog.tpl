{% for article in articles %}
<div class="article">
	<h1>{{ article.title }}</h1>
	<div class="byline">{{ article.created_at | date:"%B %d, %Y %I:%M%p"}}</div>
	{{ article.body }}
</div>
{% endfor %}
