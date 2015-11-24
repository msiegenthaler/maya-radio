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

// Remove element (by index) from a vector.
function vector_remove(vector, remove) =
  vector_flatten([for (i=[0:len(vector)-1]) (i==remove) ? [] : [vector[i]]]);

// Convert matrix to vector by keeping only the n-th column (zero based).
function vector_extract(vector, index) =
  [for (c=vector) c[index]];

// Returns true if the vector contains the value.
function vector_contains(vector, value) =
  (vector==[]) ?
    false :
    vector[0]==value || vector_contains(vector_remove(vector,0), value);

// Removes duplicates from vector.
function vector_uniq(vector) =
  (vector==[]) ? [] :
    let (tail = vector_remove(vector,0),
         uniq_tail = vector_uniq(tail),
         head = vector[0])
      vector_contains(uniq_tail, head) ?
        uniq_tail :
        concat([head], uniq_tail);

// Keeps only values in the matrix that have `value` in the `i`th column (zero based).
function vector_filter(vector, i, value) =
  vector_flatten([for (v = vector) v[i]==value ? [v] : [] ]);


// Bending
//---------
module cylindric_bend(dimensions, radius, nsteps = $fn) {
  //adapter from https://www.thingiverse.com/thing:210099/#files
  step_angle = nsteps == 0 ? $fa : atan(dimensions.y/(radius * nsteps));
  steps = nsteps == 0 ? dimensions.y/ (tan(step_angle) * radius) : nsteps;
  step_width = dimensions.y / steps;
  {
    intersection() {
      children();
      cube([dimensions.x, step_width/2, dimensions.z]);
    }
    for (step = [1:ceil(steps)]) {
      translate([0, radius * sin(step * step_angle), radius * (1 - cos(step * step_angle))])
        rotate(step_angle * step, [1, 0, 0])
          translate([0, -step * step_width, 0])
            intersection() {
              children();
              translate([0, (step - 0.5) * step_width, 0])
                cube([dimensions.x, step_width, dimensions.z]);
            }
    }
  }
}