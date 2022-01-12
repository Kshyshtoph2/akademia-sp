const getSnakeCase = (input) => {
  const lowerCased = input[0].toLowerCase() + input.slice(1);
  const output = lowerCased.replace(/([A-Z])/g, (el) => "_" + el.toLowerCase());
  console.log(input, output);
  return output;
};

module.exports = getSnakeCase;
