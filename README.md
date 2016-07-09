What's ?
===============
chef で使用する PHP の cookbook です。

Usage
-----
cookbook なので berkshelf で取ってきて使いましょう。

* Berksfile
```ruby
source "https://supermarket.chef.io"

cookbook "php", git: "https://github.com/bageljp/cookbook-php.git"
```

```
berks vendor
```

#### Role and Environment attributes

* sample_role.rb
```ruby
override_attributes(
  "php" => {
    "install_flavor" => "yum"
  }
)
```

Recipes
----------

#### php::default
phpのインストールと設定。

#### php::fpm
php-fpmの設定。

#### php::opcache
opcacheのインストールと設定。

Attributes
----------

主要なやつのみ。

#### php::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>['php']['rpm']['url']</tt></td>
    <td>string</td>
    <td>rpmでインストールする場合にrpmが置いてあるURL。rpmbuildしたものをs3とかに置いておくといいかも。</td>
  </tr>
  <tr>
    <td><tt>['php']['user']</tt></td>
    <td>string</td>
    <td>php-fpmの起動ユーザ。</td>
  </tr>
</table>

