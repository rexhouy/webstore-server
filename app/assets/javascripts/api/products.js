'use strict';

/**
 * @ngdoc function
 * @name webStore.controller:ProductsCtrl
 * @description
 * # ProductsCtrl
 * Controller of the webStoreApp
 */
angular.module('webStore')
        .controller('ProductsCtrl', function ($scope, $rootScope, $http, $location, $templateCache) {
                $scope.addToCart = function() {
                        $rootScope.layout.loading = true;
                        var formData = $('#add_to_cart_form').serializeObject();
                        $http.post('/api/carts', formData)
                                .success(function(data, status, headers, config) {
                                        $templateCache.remove('/api/carts');
                                        $location.path('/carts');
                                })
                                .error(function(data, status, headers, config) {
                                        $rootScope.layout.loading = false;
                                });
                };

                var page = 1;
                var hasProduct = true;
                $scope.products = [];
                $scope.loadProducts = function() {
                        if ($scope.loading || !hasProduct) {
                                return; // Wait loading finish
                        }
                        $scope.loading = true;
                        // Load new products
                        $http.get('/api/products/all?page='+page)
                                .success(function(data, status, headers, config) {
                                        if (!data) {
                                                alert("加载商品出错");
                                                return;
                                        }
                                        if (data.length == 0) {
                                                hasProduct = false;
                                        }
                                        data.forEach(function(product){
                                                $scope.products.push(product);
                                        });
                                        page++;
                                        $scope.loading = false;
                                })
                                .error(function(data, status, headers, config) {
                                        $scope.loading = false;
                                });
                };
        });
