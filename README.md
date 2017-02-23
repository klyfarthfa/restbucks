# Restbucks API

A standard example of an API, using Rails 5's new API-only generators.




## Known Bugs/Issues

* I did not implement a virtual barista. The pay functionality always prepares the order right after payment.

* Because of the way I made individual items in the order their own separate class, if you try to update an order via PUT
and the ids are not in the items section, it's counted as new items, and it will add new items to your order.
To update the order, you'll need to pull the ids out of the original response.

