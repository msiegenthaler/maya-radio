// Vector Utilities
//------------------

// Creates new vector of length `count` filled with `v`.
function vector_of_length(count, v=0) = [for (i = [1:count]) v];

// Creates new vector of length `count` filled with the index (starting at zero).
function vector_of_length_index(count) = [for (i = [0:count-1]) i];

// Creates a vector of `count` values distributed evenly across the `width`.
//   (i.e. 10, 20, 30 for width=40)
function vector_distribute(count, width) =
  vector_of_length_index(count, 0) * (width/(count-1));

// Lifts a vector into a matrix by concating the value with `e` for each element.
function vector_extend(vector, e) = [for (v = vector) concat([v],e)];

// Flattens a matrix into a vector (or a matrix with one less deep).
function vector_flatten(vector) = [for (a=vector) for (b=a) b];