server {
        listen   80;

        root /var/www/redmart.com/public_html;
        index index.html index.htm;

        # Make site accessible from http://localhost/
        server_name	localhost.dev;

        # ngx_pagespeed (NPS)
        pagespeed on;
        pagespeed MemcachedThreads 1;
	pagespeed MemcachedServers "localhost:11211";
        pagespeed FileCachePath /var/ngx_pagespeed_cache;
        
        # NPS Filter settings
        pagespeed RewriteLevel CoreFilters;
        pagespeed EnableFilters collapse_whitespace,lazyload_images,local_storage_cache,remove_comments;
}