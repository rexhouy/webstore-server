(function(){

        var product = function() {
                var self = {};
                var specbar = $("#specbar");
                var selectedSpec = null;
                var updateDelay = 500;

                var specExist = function() {
                        return specbar[0];
                };

                var openSpecbar = function() {
                        specbar.css("right", 0);
                };

                var updateDisplay = function(id, count, totalCount, change) {
                        var item = $("#control_"+id);
                        if (totalCount == null) {
                                var number = $(".cart-number").html();
                                totalCount = Number(number || 0);
                                if (change != null) {
                                        totalCount += change;
                                }
                        }
                        $("#cart_number").val(totalCount);
                        if (count == 0) {
                                item.find("#remove_btn_"+id).hide();
                                item.find(".count").empty().hide();
                        } else {
                                item.find("#remove_btn_"+id).show();
                                item.find(".count").html(count).show();
                        }
                        if (totalCount > 0) {
                                $(".floating-action-btn").html("<i class=\"cart-number\">"+totalCount+"</i>");
                        } else {
                                $(".floating-action-btn").html("<i class=\"glyphicon glyphicon-shopping-cart\"></i>");
                        }
                };

                var updateTimer = null;
                var updateId = null;
                var updateCount = function(id, count) {
                        if (updateTimer != null && updateId == id) {
                                clearTimeout(updateTimer);
                        }
                        updateId = id;
                        updateTimer = setTimeout(function() {
                                $.ajax("/carts/update_count/"+id, {
                                        method : 'post',
                                        headers : {
                                                'X-CSRF-Token' : utility.getCSRFtoken()
                                        },
                                        data : {
                                                count: count
                                        }
                                }).done(function(data){
                                        if (data.succeed) {
                                                // updateDisplay(id, data.count, data.totalCount);
                                        }
                                });
                        }, updateDelay);
                };

                var validCount = function(count) {
                        return count >= 0 && count < 100;
                };

                self.addToCart = function(id) {
                        var count = Number($("#product_count_"+id).html());
                        if (!validCount(++count)) {
                                return false;
                        };
                        updateDisplay(id, count, null, 1);
                        updateCount(id, count);
                        return false;
                };

                self.removeFromCart = function(id) {
                        var count = Number($("#product_count_"+id).html());
                        if (!validCount(--count)) {
                                return false;
                        };
                        updateDisplay(id, count, null, -1);
                        updateCount(id, count);
                        return false;
                };

                return self;
        };
        window.product = product();

})();
