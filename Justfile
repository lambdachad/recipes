server:
    @cook server

cost recipe:
    @cook report --template reports/cost.md.jinja {{ recipe }} --datastore . 2>/dev/null
