TRANSACTION STORAGE
=======================

Rest system for storing and analyzing payment transactions from web-based payment portals.

CONFIGURE
-----------------------

Change config/configuration.yml to suite your needs.

```
localhost:
  server:
    host:                 'http://localhost:4000'           # host name
  transaction_engine:
    host:                 'localhost'                       # transaction connection
    port:                 '4000'                                      
    ssl:                  false
    open_timeout:         5
    read_timeout:         5
    secret:               c6af25e263004d959a35f7776b0679ee  # secret used for verification
```

Run server on port 4000 (depending on your configuration).

RUNNING SYSTEM
-----------------------

```
bundle install
bundle exec rake db:migrate
bundle exec rake db:seed_fu
rails s -p 4000
```


INTERFACE
---------------------

Following methods are implemented:

```
freeze_api_account 		POST   /api/accounts/:id/freeze(.:format)     {:action=>"freeze", :controller=>"api/accounts"}
unfreeze_api_account 	POST   /api/accounts/:id/unfreeze(.:format)   {:action=>"unfreeze", :controller=>"api/accounts"}
payment_api_account 	POST   /api/accounts/:id/payment(.:format)    {:action=>"payment", :controller=>"api/accounts"}
history_api_account 	GET    /api/accounts/:id/history(.:format)    {:action=>"history", :controller=>"api/accounts"}
stats_api_account 		GET    /api/accounts/:id/stats(.:format)      {:action=>"stats", :controller=>"api/accounts"}
group_info_api_account 	GET    /api/accounts/:id/group_info(.:format) {:action=>"group_info", :controller=>"api/accounts"}
api_accounts 			GET    /api/accounts(.:format)                {:action=>"index", :controller=>"api/accounts"}
                    	POST   /api/accounts(.:format)                {:action=>"create", :controller=>"api/accounts"}
api_account 			GET    /api/accounts/:id(.:format)            {:action=>"show", :controller=>"api/accounts"}
                       	PUT    /api/accounts/:id(.:format)            {:action=>"update", :controller=>"api/accounts"}
                       	DELETE /api/accounts/:id(.:format)            {:action=>"destroy", :controller=>"api/accounts"}
```
