/** Edits the key of a object. Does NOT change that keys assigned value and index */
export const editKeyOf = (
  icon_state: { [key: string]: number },
  old_key: string,
  new_key: string,
) => {
  let returnval = {};
  Object.keys(icon_state).forEach((key) => {
    if (key === old_key) {
      const newPair = { [new_key]: icon_state[old_key] };
      returnval = { ...returnval, ...newPair };
    } else {
      returnval = { ...returnval, [key]: icon_state[key] };
    }
  });
  return returnval;
};

/** Edits the assigned weight of an object and returns the object*/
export const editWeightOf = (
  icon_state: { [key: string]: number },
  key: string,
  weight: number,
) => {
  icon_state[key] = weight;
  return icon_state;
};

/** type assertion for string[] */
export const isStringArray = (value: any): value is string[] => {
  if (!Array.isArray(value)) {
    return false;
  }
  return value.every((x) => typeof x === 'string');
};

/** sets the "space" keys value on an object, then returns that object*/
export const setGradientSpace = (
  gradient: (string | number | { space: number })[],
  space: number,
) => {
  let found = false;
  gradient?.map((entry) => {
    if (typeof entry === 'object') {
      if (Object.keys(entry)[0] === 'space') {
        entry.space = space;
        found = true;
      }
    }
  });
  if (!found) {
    gradient.push({ space: space });
  }
  return gradient;
};
