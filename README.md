# ExpressionProcessor

```ruby
expression = ExpressionProcessor::Expression.new("MAX(10, SUM(A))")
expression.constants({:A => [1,3,5]})
expression.valid?([:A]) # specify constants that are allowed
expression.eval # => 10
```


