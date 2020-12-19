#include <ruby.h>
#include <ruby/encoding.h>
#include "emoji.h"

#define unlikely(x) __builtin_expect((x),0)

static long
lookup_emoji(VALUE *rb_emoji, VALUE rb_bytes, VALUE rb_unicode_map, const long *possible_len)
{
	const uint8_t *src = (uint8_t *)RSTRING_PTR(rb_bytes);

	for (; *possible_len; ++possible_len) {
		const long emoji_size = *possible_len;

		if (emoji_size > RSTRING_LEN(rb_bytes))
			continue;

		if ((src[emoji_size - 1] & 0xC0) != 0x80)
			continue;

		rb_str_set_len(rb_bytes, emoji_size);

		*rb_emoji = rb_hash_lookup(rb_unicode_map, rb_bytes);
		if (!NIL_P(*rb_emoji))
			return emoji_size;
	}

	return 0;
}

static VALUE
replace_emoji(const uint8_t *src, long size, VALUE rb_unicode_map)
{
	VALUE rb_emoji, rb_bytes, rb_out = Qnil;
	long i = 0, org, emoji_len;
	int8_t emoji_byte;

	while (i < size) {
		org = i;

retry_search:
		while (i < size && (emoji_byte = emoji_magic_bytes[(int)src[i]]) == 0)
			i++;

		if (i + 1 < size && (src[i + 1] & 0x80) != 0x80) {
			i++;
			goto retry_search;
		}

		if (unlikely(org == 0)) {
			if (i == size)
				return Qnil;

			rb_out = rb_str_buf_new(size * 4 / 3);
			rb_enc_associate(rb_out, rb_utf8_encoding());

			rb_bytes = rb_str_buf_new(16);
			rb_enc_associate(rb_bytes, rb_utf8_encoding());
		}

		if (i > org)
			rb_str_buf_cat(rb_out, (const char *)src + org, i - org);

		if (unlikely(i == size))
			break;

		emoji_len = size - i;
		if (emoji_len > 12)
			emoji_len = 12;

		memcpy(RSTRING_PTR(rb_bytes), src + i, emoji_len);
		rb_str_set_len(rb_bytes, emoji_len);

		emoji_len = lookup_emoji(&rb_emoji, rb_bytes, rb_unicode_map, emoji_byte_lengths[(int)emoji_byte]);

		if (emoji_len) {
			VALUE rb_repl = rb_yield(rb_emoji);

			if (NIL_P(rb_repl)) {
				rb_str_buf_cat(rb_out, (const char *)src + i, emoji_len);
			} else {
				Check_Type(rb_repl, T_STRING);
				rb_str_buf_append(rb_out, rb_repl);
			}

			i += emoji_len;
			continue;
		}

		rb_str_buf_cat(rb_out, (const char *)src + i, 1);
		i++;
	}

	return rb_out;
}

static VALUE
rb_gemoji_replace_unicode(VALUE klass, VALUE rb_source)
{
	VALUE rb_output;
	VALUE rb_unicode_map = rb_funcall(klass, rb_intern("unicodes_index"), 0);

	Check_Type(rb_source, T_STRING);
	Check_Type(rb_unicode_map, T_HASH);

	rb_must_asciicompat(rb_source);

	if (ENC_CODERANGE_ASCIIONLY(rb_source))
		return rb_source;

	if (rb_enc_get(rb_source) != rb_utf8_encoding())
		rb_raise(rb_eEncCompatError, "expected UTF-8 encoding");

	rb_output = replace_emoji((uint8_t *)RSTRING_PTR(rb_source), RSTRING_LEN(rb_source), rb_unicode_map);
	if (NIL_P(rb_output))
		return rb_source;

	return rb_output;
}

void Init_gemoji(void)
{
	VALUE rb_mEmoji = rb_define_module("Emoji");
	rb_define_method(rb_mEmoji, "gsub_unicode", rb_gemoji_replace_unicode, 1);
}
