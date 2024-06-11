shader_type canvas_item;

#define DEBUG_MODE_ON
#include "res://debug_utils.gdshaderinc"

// all data types
group_uniforms all_data_types;
group_uniforms all_data_types.booleans;
uniform bool boolean;
uniform bvec2 boolean_vec2;
uniform bvec3 boolean_vec3;
uniform bvec4 boolean_vec4;
group_uniforms;
group_uniforms all_data_types.integers;
uniform int integer;
uniform ivec2 integer_vec2;
uniform ivec3 integer_vec3;
uniform ivec4 integer_vec4;
uniform uint unsigned_integer;
uniform uvec2 unsigned_integer_vec2;
uniform uvec3 unsigned_integer_vec3;
uniform uvec4 unsigned_integer_vec4;
group_uniforms;
group_uniforms all_data_types.floats;
uniform float _float;
uniform vec2 float_vec2;
uniform vec3 float_vec3;
uniform vec4 float_vec4;
group_uniforms;
group_uniforms all_data_types.matrix;
uniform mat2 matrix_2;
uniform mat3 matrix_3;
group_uniforms;
group_uniforms all_data_types.sampler_2D;
uniform sampler2D sampler_2d;
uniform isampler2D integer_sampler_2d;
uniform usampler2D unsigned_integer_sampler_2d;
uniform sampler2DArray sampler_2d_array;
uniform isampler2DArray integer_sampler_2d_array;
uniform usampler2DArray unsigned_integer_sampler_2d_array;
group_uniforms;

// uniforms used for code examples
group_uniforms data_type_examples;
group_uniforms data_type_examples.boolean;
uniform bool u_visible;
group_uniforms;
group_uniforms data_type_examples.boolean_vector;
uniform bvec2 u_toggleEffects;
group_uniforms;
group_uniforms data_type_examples.unsigned_integer;
uniform uint frame_index = 0;
uniform uint frame_amount = 1;
group_uniforms;
group_uniforms data_type_examples.vector_3;
uniform vec3 color_scale = vec3(1.0);
group_uniforms;
group_uniforms data_type_examples.sampler_2d;
uniform sampler2D u_texture;
group_uniforms;
group_uniforms data_type_examples.float_range;
uniform float float_range : hint_range(0, 1) = 0.5;
group_uniforms;
group_uniforms data_type_examples.color;
uniform vec3 color : source_color = vec3(1.0, 0.0, 0.0);
group_uniforms;

void vertex() {
	// called for every vertex
}

void fragment() {
	// called for every pixel
	#ifdef DEBUG_MODE_ON
	debug_draw_dots_at_vertices(UV, COLOR, TEXTURE);
	#endif
}