
print("reading file")
fruit <- read.csv(file = 'analyses/data/raw-data/fruits.csv')

print('selecting fruits with price of 2')
df <- fruit[is.element(fruit$price, c(2)),]

print('writing file to a csv file')
write.csv(df, file='analyses/data/derived-data/output_price2.csv')