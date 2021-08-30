 extern record _GTimeVal {
   var tv_sec : glong;
   var tv_usec : glong;
}
 extern record _GArray {
   var data : c_ptr(gchar);
   var len : guint;
}
 extern record _GByteArray {
   var data : c_ptr(guint8);
   var len : guint;
}
 extern record _GPtrArray {
   var pdata : c_ptr(gpointer);
   var len : guint;
}
 extern record _GError {
   extern "domain" var dom: GQuark;
   var code: gint;
   var message: c_ptr(gchar);
}
 extern record _GDebugKey {
   var key : c_ptr(gchar);
   var value : guint;
}
 extern record _GRWLock {
   var p : gpointer;
   var i : c_ptr(guint);
}
 extern record _GCond {
   var p : gpointer;
   var i : c_ptr(guint);
}
 extern record _GRecMutex {
   var p : gpointer;
   var i : c_ptr(guint);
}
 extern record _GPrivate {
   var p : gpointer;
   var notify : GDestroyNotify;
   var future : c_ptr(gpointer);
}
 extern record _GOnce {
   var status : GOnceStatus;
   var retval : gpointer;
}
 extern record _GDate {
   var julian_days : guint;
   var julian : guint;
   var dmy : guint;
   var day : guint;
   var month : guint;
   var year : guint;
}
 extern record _GMemVTable {
   var malloc : c_ptr(c_fn_ptr);
   var realloc : c_ptr(c_fn_ptr);
   var free : c_ptr(c_fn_ptr);
   var calloc : c_ptr(c_fn_ptr);
   var try_malloc : c_ptr(c_fn_ptr);
   var try_realloc : c_ptr(c_fn_ptr);
}
 extern record _GNode {
   var data : gpointer;
   var next : c_ptr(_GNode);
   var prev : c_ptr(_GNode);
   var parent : c_ptr(_GNode);
   var children : c_ptr(_GNode);
}
 extern record _GList {
   var data : gpointer;
   var next : c_ptr(GList);
   var prev : c_ptr(GList);
}
 extern record _GHashTableIter {
   var dummy1 : gpointer;
   var dummy2 : gpointer;
   var dummy3 : gpointer;
   var dummy4 : c_int;
   var dummy5 : gboolean;
   var dummy6 : gpointer;
}
 extern record _GHookList {
   var seq_id : gulong;
   var hook_size : guint;
   var is_setup : guint;
   var hooks : c_ptr(GHook);
   var dummy3 : gpointer;
   var finalize_hook : GHookFinalizeFunc;
   var dummy : c_ptr(gpointer);
}
 extern record _GHook {
   var data : gpointer;
   var next : c_ptr(_GHook);
   var prev : c_ptr(_GHook);
   var ref_count : guint;
   var hook_id : gulong;
   var flags : guint;
   var func : gpointer;
   var destroy : GDestroyNotify;
}
 extern record _GPollFD {
   var fd : gint;
   var events : gushort;
   var revents : gushort;
}
 extern record _GSList {
   var data : gpointer;
   var next : c_ptr(GSList);
}
 extern record _GSource {
   var callback_data : gpointer;
   var callback_funcs : c_ptr(GSourceCallbackFuncs);
   var source_funcs : c_ptr(GSourceFuncs);
   var ref_count : guint;
   var context : c_ptr(GMainContext);
   var priority : gint;
   var flags : guint;
   var source_id : guint;
   var poll_fds : c_ptr(GSList);
   var prev : c_ptr(_GSource);
   var next : c_ptr(_GSource);
   var name : c_string;
   var priv : c_ptr(GSourcePrivate);
}
}
 extern record _GSourceFuncs {
   var prepare : c_ptr(c_fn_ptr);
   var check : c_ptr(c_fn_ptr);
   var dispatch : c_ptr(c_fn_ptr);
   var finalize : c_ptr(c_fn_ptr);
   var closure_callback : GSourceFunc;
   var closure_marshal : GSourceDummyMarshal;
}
 extern record _GString {
   var str : c_ptr(gchar);
   var len : gsize;
   var allocated_len : gsize;
}
 extern record _GIOChannel {
   var ref_count : gint;
   var funcs : c_ptr(GIOFuncs);
   var encoding : c_ptr(gchar);
   var read_cd : GIConv;
   var write_cd : GIConv;
   var line_term : c_ptr(gchar);
   var line_term_len : guint;
   var buf_size : gsize;
   var read_buf : c_ptr(GString);
   var encoded_read_buf : c_ptr(GString);
   var write_buf : c_ptr(GString);
   var partial_write_buf : c_ptr(gchar);
   var use_buffer : guint;
   var do_encode : guint;
   var close_on_unref : guint;
   var is_readable : guint;
   var is_writeable : guint;
   var is_seekable : guint;
   var reserved1 : gpointer;
   var reserved2 : gpointer;
}
 extern record _GIOFuncs {
   var io_read : c_ptr(c_fn_ptr);
   var io_write : c_ptr(c_fn_ptr);
   var io_seek : c_ptr(c_fn_ptr);
   var io_close : c_ptr(c_fn_ptr);
   var io_create_watch : c_ptr(c_fn_ptr);
   var io_free : c_ptr(c_fn_ptr);
   var io_set_flags : c_ptr(c_fn_ptr);
   var io_get_flags : c_ptr(c_fn_ptr);
}
 extern record _GMarkupParser {
   var start_element : c_ptr(c_fn_ptr);
   var end_element : c_ptr(c_fn_ptr);
   var text : c_ptr(c_fn_ptr);
   var passthrough : c_ptr(c_fn_ptr);
   var error : c_ptr(c_fn_ptr);
}
 extern record _GVariantIter {
   var x : c_ptr(gsize);
}
}
}
 extern record _GLogField {
   var key : c_ptr(gchar);
   var value : gconstpointer;
   var length : gssize;
}
 extern record _GOptionEntry {
   var long_name : c_ptr(gchar);
   var short_name : gchar;
   var flags : gint;
   var arg : GOptionArg;
   var arg_data : gpointer;
   var description : c_ptr(gchar);
   var arg_description : c_ptr(gchar);
}
 extern record _GQueue {
   var head : c_ptr(GList);
   var tail : c_ptr(GList);
   var length : guint;
}
 extern record _GScannerConfig {
   var cset_skip_characters : c_ptr(gchar);
   var cset_identifier_first : c_ptr(gchar);
   var cset_identifier_nth : c_ptr(gchar);
   var cpair_comment_single : c_ptr(gchar);
   var case_sensitive : guint;
   var skip_comment_multi : guint;
   var skip_comment_single : guint;
   var scan_comment_multi : guint;
   var scan_identifier : guint;
   var scan_identifier_1char : guint;
   var scan_identifier_NULL : guint;
   var scan_symbols : guint;
   var scan_binary : guint;
   var scan_octal : guint;
   var scan_float : guint;
   var scan_hex : guint;
   var scan_hex_dollar : guint;
   var scan_string_sq : guint;
   var scan_string_dq : guint;
   var numbers_2_int : guint;
   var int_2_float : guint;
   var identifier_2_string : guint;
   var char_2_token : guint;
   var symbol_2_token : guint;
   var scope_0_fallback : guint;
   var store_int64 : guint;
   var padding_dummy : guint;
}
}
 extern record _GThreadPool {
   var func : GFunc;
   var user_data : gpointer;
   var exclusive : gboolean;
}
 extern record _GTrashStack {
   var next : c_ptr(_GTrashStack);
}
 extern record _GUriParamsIter {
   var dummy0 : gint;
   var dummy1 : gpointer;
   var dummy2 : gpointer;
   var dummy3 : c_ptr(guint8);
}
 extern record _GCompletion {
   var items : c_ptr(GList);
   var func : GCompletionFunc;
   var prefix : c_ptr(gchar);
   var cache : c_ptr(GList);
   var strncmp_func : GCompletionStrncmpFunc;
}
 extern record _GTuples {
   var len : guint;
}
 extern record _GThread {
   var func : GThreadFunc;
   var data : gpointer;
   var joinable : gboolean;
   var priority : GThreadPriority;
}
 extern record _GThreadFunctions {
   var mutex_new : c_ptr(c_fn_ptr);
   var mutex_lock : c_ptr(c_fn_ptr);
   var mutex_trylock : c_ptr(c_fn_ptr);
   var mutex_unlock : c_ptr(c_fn_ptr);
   var mutex_free : c_ptr(c_fn_ptr);
   var cond_new : c_ptr(c_fn_ptr);
   var cond_signal : c_ptr(c_fn_ptr);
   var cond_broadcast : c_ptr(c_fn_ptr);
   var cond_wait : c_ptr(c_fn_ptr);
   var cond_timed_wait : c_ptr(c_fn_ptr);
   var cond_free : c_ptr(c_fn_ptr);
   var private_new : c_ptr(c_fn_ptr);
   var private_get : c_ptr(c_fn_ptr);
   var private_set : c_ptr(c_fn_ptr);
   var thread_create : c_ptr(c_fn_ptr);
   var thread_yield : c_ptr(c_fn_ptr);
   var thread_join : c_ptr(c_fn_ptr);
   var thread_exit : c_ptr(c_fn_ptr);
   var thread_set_priority : c_ptr(c_fn_ptr);
   var thread_self : c_ptr(c_fn_ptr);
   var thread_equal : c_ptr(c_fn_ptr);
}
 extern record _GStaticRecMutex {
   var mutex : GStaticMutex;
   var depth : guint;
}
 extern record _GStaticRWLock {
   var mutex : GStaticMutex;
   var read_cond : c_ptr(GCond);
   var write_cond : c_ptr(GCond);
   var read_counter : guint;
   var have_writer : gboolean;
   var want_to_read : guint;
   var want_to_write : guint;
}
}
 extern record _GTypeClass {
   var g_type : GType;
}
 extern record _GTypeInstance {
   var g_class : c_ptr(GTypeClass);
}
 extern record _GTypeInterface {
   var g_type : GType;
   var g_instance_type : GType;
}
}
 extern record _GTypeInfo {
   var class_size : guint16;
   var base_init : GBaseInitFunc;
   var base_finalize : GBaseFinalizeFunc;
   var class_init : GClassInitFunc;
   var class_finalize : GClassFinalizeFunc;
   var class_data : gconstpointer;
   var instance_size : guint16;
   var n_preallocs : guint16;
   var instance_init : GInstanceInitFunc;
   var value_table : c_ptr(GTypeValueTable);
}
 extern record _GTypeFundamentalInfo {
   var type_flags : GTypeFundamentalFlags;
}
 extern record _GInterfaceInfo {
   var interface_init : GInterfaceInitFunc;
   var interface_finalize : GInterfaceFinalizeFunc;
   var interface_data : gpointer;
}
 extern record _GTypeValueTable {
   var value_init : c_ptr(c_fn_ptr);
   var value_free : c_ptr(c_fn_ptr);
   var value_copy : c_ptr(c_fn_ptr);
   var value_peek_pointer : c_ptr(c_fn_ptr);
   var collect_format : c_ptr(gchar);
   var collect_value : c_ptr(c_fn_ptr);
   var lcopy_format : c_ptr(gchar);
   var lcopy_value : c_ptr(c_fn_ptr);
}
 extern record _GValue {
   var g_type : GType;
}
 extern record _GParamSpec {
   var g_type_instance : GTypeInstance;
   var name : c_ptr(gchar);
   var flags : GParamFlags;
   var value_type : GType;
   var owner_type : GType;
   var _nick : c_ptr(gchar);
   var _blurb : c_ptr(gchar);
   var qdata : c_ptr(GData);
   var ref_count : guint;
   var param_id : guint;
}
 extern record _GParamSpecClass {
   var g_type_class : GTypeClass;
   var value_type : GType;
   var finalize : c_ptr(c_fn_ptr);
   var value_set_default : c_ptr(c_fn_ptr);
   var value_validate : c_ptr(c_fn_ptr);
   var values_cmp : c_ptr(c_fn_ptr);
   var dummy : c_ptr(gpointer);
}
 extern record _GParameter {
   var name : c_ptr(gchar);
   var value : GValue;
}
 extern record _GParamSpecTypeInfo {
   var instance_size : guint16;
   var n_preallocs : guint16;
   var instance_init : c_ptr(c_fn_ptr);
   var value_type : GType;
   var finalize : c_ptr(c_fn_ptr);
   var value_set_default : c_ptr(c_fn_ptr);
   var value_validate : c_ptr(c_fn_ptr);
   var values_cmp : c_ptr(c_fn_ptr);
}
 extern record _GClosureNotifyData {
   var data : gpointer;
   var notify : GClosureNotify;
}
 extern record _GClosure {
   var ref_count : guint;
   var meta_marshal_nouse : guint;
   var n_guards : guint;
   var n_fnotifiers : guint;
   var n_inotifiers : guint;
   var in_inotify : guint;
   var floating : guint;
   var derivative_flag : guint;
   var in_marshal : guint;
   var is_invalid : guint;
   var marshal : c_ptr(c_fn_ptr);
   var data : gpointer;
   var notifiers : c_ptr(GClosureNotifyData);
}
 extern record _GCClosure {
   var closure : GClosure;
   var callback : gpointer;
}
 extern record _GSignalInvocationHint {
   var signal_id : guint;
   var detail : GQuark;
   var run_type : GSignalFlags;
}
 extern record _GSignalQuery {
   var signal_id : guint;
   var signal_name : c_ptr(gchar);
   var itype : GType;
   var signal_flags : GSignalFlags;
   var return_type : GType;
   var n_params : guint;
   var param_types : c_ptr(GType);
}
 extern record _GObject {
   var g_type_instance : GTypeInstance;
   var ref_count : guint;
   var qdata : c_ptr(GData);
}
 extern record _GObjectClass {
   var g_type_class : GTypeClass;
   var construct_properties : c_ptr(GSList);
   var constructor : c_ptr(c_fn_ptr);
   var set_property : c_ptr(c_fn_ptr);
   var get_property : c_ptr(c_fn_ptr);
   var dispose : c_ptr(c_fn_ptr);
   var finalize : c_ptr(c_fn_ptr);
   var dispatch_properties_changed : c_ptr(c_fn_ptr);
   var notify : c_ptr(c_fn_ptr);
   var constructed : c_ptr(c_fn_ptr);
   var flags : gsize;
   var pdummy : c_ptr(gpointer);
}
 extern record _GObjectConstructParam {
   var pspec : c_ptr(GParamSpec);
   var value : c_ptr(GValue);
}
 extern record _GEnumClass {
   var g_type_class : GTypeClass;
   var minimum : gint;
   var maximum : gint;
   var n_values : guint;
   var values : c_ptr(GEnumValue);
}
 extern record _GFlagsClass {
   var g_type_class : GTypeClass;
   var mask : guint;
   var n_values : guint;
   var values : c_ptr(GFlagsValue);
}
 extern record _GEnumValue {
   var value : gint;
   var value_name : c_ptr(gchar);
   var value_nick : c_ptr(gchar);
}
 extern record _GFlagsValue {
   var value : guint;
   var value_name : c_ptr(gchar);
   var value_nick : c_ptr(gchar);
}
 extern record _GParamSpecChar {
   var parent_instance : GParamSpec;
   var minimum : gint8;
   var maximum : gint8;
   var default_value : gint8;
}
 extern record _GParamSpecUChar {
   var parent_instance : GParamSpec;
   var minimum : guint8;
   var maximum : guint8;
   var default_value : guint8;
}
 extern record _GParamSpecBoolean {
   var parent_instance : GParamSpec;
   var default_value : gboolean;
}
 extern record _GParamSpecInt {
   var parent_instance : GParamSpec;
   var minimum : gint;
   var maximum : gint;
   var default_value : gint;
}
 extern record _GParamSpecUInt {
   var parent_instance : GParamSpec;
   var minimum : guint;
   var maximum : guint;
   var default_value : guint;
}
 extern record _GParamSpecLong {
   var parent_instance : GParamSpec;
   var minimum : glong;
   var maximum : glong;
   var default_value : glong;
}
 extern record _GParamSpecULong {
   var parent_instance : GParamSpec;
   var minimum : gulong;
   var maximum : gulong;
   var default_value : gulong;
}
 extern record _GParamSpecInt64 {
   var parent_instance : GParamSpec;
   var minimum : gint64;
   var maximum : gint64;
   var default_value : gint64;
}
 extern record _GParamSpecUInt64 {
   var parent_instance : GParamSpec;
   var minimum : guint64;
   var maximum : guint64;
   var default_value : guint64;
}
 extern record _GParamSpecUnichar {
   var parent_instance : GParamSpec;
   var default_value : gunichar;
}
 extern record _GParamSpecEnum {
   var parent_instance : GParamSpec;
   var enum_class : c_ptr(GEnumClass);
   var default_value : gint;
}
 extern record _GParamSpecFlags {
   var parent_instance : GParamSpec;
   var flags_class : c_ptr(GFlagsClass);
   var default_value : guint;
}
 extern record _GParamSpecFloat {
   var parent_instance : GParamSpec;
   var minimum : gfloat;
   var maximum : gfloat;
   var default_value : gfloat;
   var epsilon : gfloat;
}
 extern record _GParamSpecDouble {
   var parent_instance : GParamSpec;
   var minimum : gdouble;
   var maximum : gdouble;
   var default_value : gdouble;
   var epsilon : gdouble;
}
 extern record _GParamSpecString {
   var parent_instance : GParamSpec;
   var default_value : c_ptr(gchar);
   var cset_first : c_ptr(gchar);
   var cset_nth : c_ptr(gchar);
   var substitutor : gchar;
   var null_fold_if_empty : guint;
   var ensure_non_null : guint;
}
 extern record _GParamSpecParam {
   var parent_instance : GParamSpec;
}
 extern record _GParamSpecBoxed {
   var parent_instance : GParamSpec;
}
 extern record _GParamSpecPointer {
   var parent_instance : GParamSpec;
}
 extern record _GParamSpecValueArray {
   var parent_instance : GParamSpec;
   var element_spec : c_ptr(GParamSpec);
   var fixed_n_elements : guint;
}
 extern record _GParamSpecObject {
   var parent_instance : GParamSpec;
}
 extern record _GParamSpecOverride {
   var parent_instance : GParamSpec;
   var overridden : c_ptr(GParamSpec);
}
 extern record _GParamSpecGType {
   var parent_instance : GParamSpec;
   var is_a_type : GType;
}
}
 extern record _GTypeModule {
   var parent_instance : GObject;
   var use_count : guint;
   var type_infos : c_ptr(GSList);
   var interface_infos : c_ptr(GSList);
   var name : c_ptr(gchar);
}
 extern record _GTypeModuleClass {
   var parent_class : GObjectClass;
   var load : c_ptr(c_fn_ptr);
   var unload : c_ptr(c_fn_ptr);
   var reserved1 : c_ptr(c_fn_ptr);
   var reserved2 : c_ptr(c_fn_ptr);
   var reserved3 : c_ptr(c_fn_ptr);
   var reserved4 : c_ptr(c_fn_ptr);
}
 extern record _GTypePluginClass {
   var base_iface : GTypeInterface;
   var use_plugin : GTypePluginUse;
   var unuse_plugin : GTypePluginUnuse;
   var complete_type_info : GTypePluginCompleteTypeInfo;
   var complete_interface_info : GTypePluginCompleteInterfaceInfo;
}
 extern record _GValueArray {
   var n_values : guint;
   var values : c_ptr(GValue);
   var n_prealloced : guint;
}
 extern record _GArrowDecimal128 {
   var parent_instance : GObject;
}
 extern record _GArrowDecimal128Class {
   var parent_class : GObjectClass;
}
 extern record _GArrowDecimal256 {
   var parent_instance : GObject;
}
 extern record _GArrowDecimal256Class {
   var parent_class : GObjectClass;
}
 extern record _GArrowDataType {
   var parent_instance : GObject;
}
 extern record _GArrowDataTypeClass {
   var parent_class : GObjectClass;
}
 extern record _GArrowFixedWidthDataType {
   var parent_instance : GArrowDataType;
}
 extern record _GArrowFixedWidthDataTypeClass {
   var parent_class : GArrowDataTypeClass;
}
 extern record _GArrowNullDataType {
   var parent_instance : GArrowDataType;
}
 extern record _GArrowNullDataTypeClass {
   var parent_class : GArrowDataTypeClass;
}
 extern record _GArrowBooleanDataType {
   var parent_instance : GArrowFixedWidthDataType;
}
 extern record _GArrowBooleanDataTypeClass {
   var parent_class : GArrowFixedWidthDataTypeClass;
}
 extern record _GArrowNumericDataType {
   var parent_instance : GArrowFixedWidthDataType;
}
 extern record _GArrowNumericDataTypeClass {
   var parent_class : GArrowFixedWidthDataTypeClass;
}
 extern record _GArrowIntegerDataType {
   var parent_instance : GArrowNumericDataType;
}
 extern record _GArrowIntegerDataTypeClass {
   var parent_class : GArrowNumericDataTypeClass;
}
 extern record _GArrowInt8DataType {
   var parent_instance : GArrowIntegerDataType;
}
 extern record _GArrowInt8DataTypeClass {
   var parent_class : GArrowIntegerDataTypeClass;
}
 extern record _GArrowUInt8DataType {
   var parent_instance : GArrowIntegerDataType;
}
 extern record _GArrowUInt8DataTypeClass {
   var parent_class : GArrowIntegerDataTypeClass;
}
 extern record _GArrowInt16DataType {
   var parent_instance : GArrowIntegerDataType;
}
 extern record _GArrowInt16DataTypeClass {
   var parent_class : GArrowIntegerDataTypeClass;
}
 extern record _GArrowUInt16DataType {
   var parent_instance : GArrowIntegerDataType;
}
 extern record _GArrowUInt16DataTypeClass {
   var parent_class : GArrowIntegerDataTypeClass;
}
 extern record _GArrowInt32DataType {
   var parent_instance : GArrowIntegerDataType;
}
 extern record _GArrowInt32DataTypeClass {
   var parent_class : GArrowIntegerDataTypeClass;
}
 extern record _GArrowUInt32DataType {
   var parent_instance : GArrowIntegerDataType;
}
 extern record _GArrowUInt32DataTypeClass {
   var parent_class : GArrowIntegerDataTypeClass;
}
 extern record _GArrowInt64DataType {
   var parent_instance : GArrowIntegerDataType;
}
 extern record _GArrowInt64DataTypeClass {
   var parent_class : GArrowIntegerDataTypeClass;
}
 extern record _GArrowUInt64DataType {
   var parent_instance : GArrowIntegerDataType;
}
 extern record _GArrowUInt64DataTypeClass {
   var parent_class : GArrowIntegerDataTypeClass;
}
 extern record _GArrowFloatingPointDataType {
   var parent_instance : GArrowNumericDataType;
}
 extern record _GArrowFloatingPointDataTypeClass {
   var parent_class : GArrowNumericDataTypeClass;
}
 extern record _GArrowFloatDataType {
   var parent_instance : GArrowFloatingPointDataType;
}
 extern record _GArrowFloatDataTypeClass {
   var parent_class : GArrowFloatingPointDataTypeClass;
}
 extern record _GArrowDoubleDataType {
   var parent_instance : GArrowFloatingPointDataType;
}
 extern record _GArrowDoubleDataTypeClass {
   var parent_class : GArrowFloatingPointDataTypeClass;
}
 extern record _GArrowBinaryDataType {
   var parent_instance : GArrowDataType;
}
 extern record _GArrowBinaryDataTypeClass {
   var parent_class : GArrowDataTypeClass;
}
 extern record _GArrowFixedSizeBinaryDataType {
   var parent_instance : GArrowDataType;
}
 extern record _GArrowFixedSizeBinaryDataTypeClass {
   var parent_class : GArrowFixedWidthDataTypeClass;
}
 extern record _GArrowLargeBinaryDataType {
   var parent_instance : GArrowDataType;
}
 extern record _GArrowLargeBinaryDataTypeClass {
   var parent_class : GArrowDataTypeClass;
}
 extern record _GArrowStringDataType {
   var parent_instance : GArrowBinaryDataType;
}
 extern record _GArrowStringDataTypeClass {
   var parent_class : GArrowBinaryDataTypeClass;
}
 extern record _GArrowLargeStringDataType {
   var parent_instance : GArrowLargeBinaryDataType;
}
 extern record _GArrowLargeStringDataTypeClass {
   var parent_class : GArrowLargeBinaryDataTypeClass;
}
 extern record _GArrowDate32DataType {
   var parent_instance : GArrowDataType;
}
 extern record _GArrowDate32DataTypeClass {
   var parent_class : GArrowDataTypeClass;
}
 extern record _GArrowDate64DataType {
   var parent_instance : GArrowDataType;
}
 extern record _GArrowDate64DataTypeClass {
   var parent_class : GArrowDataTypeClass;
}
 extern record _GArrowTimestampDataType {
   var parent_instance : GArrowDataType;
}
 extern record _GArrowTimestampDataTypeClass {
   var parent_class : GArrowDataTypeClass;
}
 extern record _GArrowTimeDataType {
   var parent_instance : GArrowDataType;
}
 extern record _GArrowTimeDataTypeClass {
   var parent_class : GArrowDataTypeClass;
}
 extern record _GArrowTime32DataType {
   var parent_instance : GArrowTimeDataType;
}
 extern record _GArrowTime32DataTypeClass {
   var parent_class : GArrowTimeDataTypeClass;
}
 extern record _GArrowTime64DataType {
   var parent_instance : GArrowTimeDataType;
}
 extern record _GArrowTime64DataTypeClass {
   var parent_class : GArrowTimeDataTypeClass;
}
 extern record _GArrowDecimalDataType {
   var parent_instance : GArrowFixedSizeBinaryDataType;
}
 extern record _GArrowDecimalDataTypeClass {
   var parent_class : GArrowFixedSizeBinaryDataTypeClass;
}
 extern record _GArrowDecimal128DataType {
   var parent_instance : GArrowDecimalDataType;
}
 extern record _GArrowDecimal128DataTypeClass {
   var parent_class : GArrowDecimalDataTypeClass;
}
 extern record _GArrowDecimal256DataType {
   var parent_instance : GArrowDecimalDataType;
}
 extern record _GArrowDecimal256DataTypeClass {
   var parent_class : GArrowDecimalDataTypeClass;
}
 extern record _GArrowExtensionDataType {
   var parent_instance : GArrowDataType;
}
 extern record _GArrowExtensionDataTypeClass {
   var parent_class : GArrowDataTypeClass;
   var get_extension_name : c_ptr(c_fn_ptr);
   var equal : c_ptr(c_fn_ptr);
   var deserialize : c_ptr(c_fn_ptr);
   var serialize : c_ptr(c_fn_ptr);
   var get_array_gtype : c_ptr(c_fn_ptr);
}
 extern record _GArrowExtensionDataTypeRegistry {
   var parent_instance : GObject;
}
 extern record _GArrowExtensionDataTypeRegistryClass {
   var parent_class : GObjectClass;
}
 extern record _GArrowBuffer {
   var parent_instance : GObject;
}
 extern record _GArrowBufferClass {
   var parent_class : GObjectClass;
}
 extern record _GArrowMutableBuffer {
   var parent_instance : GArrowBuffer;
}
 extern record _GArrowMutableBufferClass {
   var parent_class : GArrowBufferClass;
}
 extern record _GArrowResizableBuffer {
   var parent_instance : GArrowMutableBuffer;
}
 extern record _GArrowResizableBufferClass {
   var parent_class : GArrowMutableBufferClass;
}
 extern record _GArrowEqualOptions {
   var parent_instance : GObject;
}
 extern record _GArrowEqualOptionsClass {
   var parent_class : GObjectClass;
}
 extern record _GArrowArray {
   var parent_instance : GObject;
}
 extern record _GArrowArrayClass {
   var parent_class : GObjectClass;
}
 extern record _GArrowNullArray {
   var parent_instance : GArrowArray;
}
 extern record _GArrowNullArrayClass {
   var parent_class : GArrowArrayClass;
}
 extern record _GArrowPrimitiveArray {
   var parent_instance : GArrowArray;
}
 extern record _GArrowPrimitiveArrayClass {
   var parent_class : GArrowArrayClass;
}
 extern record _GArrowBooleanArray {
   var parent_instance : GArrowPrimitiveArray;
}
 extern record _GArrowBooleanArrayClass {
   var parent_class : GArrowPrimitiveArrayClass;
}
 extern record _GArrowNumericArray {
   var parent_instance : GArrowPrimitiveArray;
}
 extern record _GArrowNumericArrayClass {
   var parent_class : GArrowPrimitiveArrayClass;
}
 extern record _GArrowInt8Array {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowInt8ArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowUInt8Array {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowUInt8ArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowInt16Array {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowInt16ArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowUInt16Array {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowUInt16ArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowInt32Array {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowInt32ArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowUInt32Array {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowUInt32ArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowInt64Array {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowInt64ArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowUInt64Array {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowUInt64ArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowFloatArray {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowFloatArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowDoubleArray {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowDoubleArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowBinaryArray {
   var parent_instance : GArrowArray;
}
 extern record _GArrowBinaryArrayClass {
   var parent_class : GArrowArrayClass;
}
 extern record _GArrowLargeBinaryArray {
   var parent_instance : GArrowArray;
}
 extern record _GArrowLargeBinaryArrayClass {
   var parent_class : GArrowArrayClass;
}
 extern record _GArrowStringArray {
   var parent_instance : GArrowBinaryArray;
}
 extern record _GArrowStringArrayClass {
   var parent_class : GArrowBinaryArrayClass;
}
 extern record _GArrowLargeStringArray {
   var parent_instance : GArrowLargeBinaryArray;
}
 extern record _GArrowLargeStringArrayClass {
   var parent_class : GArrowLargeBinaryArrayClass;
}
 extern record _GArrowDate32Array {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowDate32ArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowDate64Array {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowDate64ArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowTimestampArray {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowTimestampArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowTime32Array {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowTime32ArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowTime64Array {
   var parent_instance : GArrowNumericArray;
}
 extern record _GArrowTime64ArrayClass {
   var parent_class : GArrowNumericArrayClass;
}
 extern record _GArrowFixedSizeBinaryArray {
   var parent_instance : GArrowPrimitiveArray;
}
 extern record _GArrowFixedSizeBinaryArrayClass {
   var parent_class : GArrowPrimitiveArrayClass;
}
 extern record _GArrowDecimal128Array {
   var parent_instance : GArrowFixedSizeBinaryArray;
}
 extern record _GArrowDecimal128ArrayClass {
   var parent_class : GArrowFixedSizeBinaryArrayClass;
}
 extern record _GArrowDecimal256Array {
   var parent_instance : GArrowFixedSizeBinaryArray;
}
extern record _GArrowDecimal256ArrayClass {
  var parent_class : GArrowFixedSizeBinaryArrayClass;
}
extern record _GArrowExtensionArray {
  var parent_instance : GArrowArray;
}
extern record _GArrowExtensionArrayClass {
  var parent_class : GArrowArrayClass;
}
extern record _GArrowField {
  var parent_instance : GObject;
}
extern record _GArrowFieldClass {
  var parent_class : GObjectClass;
}
extern record _GArrowListDataType {
  var parent_instance : GArrowDataType;
}
extern record _GArrowListDataTypeClass {
  var parent_class : GArrowDataTypeClass;
}
extern record _GArrowLargeListDataType {
  var parent_instance : GArrowDataType;
}
extern record _GArrowLargeListDataTypeClass {
  var parent_class : GArrowDataTypeClass;
}
extern record _GArrowStructDataType {
  var parent_instance : GArrowDataType;
}
extern record _GArrowStructDataTypeClass {
  var parent_class : GArrowDataTypeClass;
}
extern record _GArrowMapDataType {
  var parent_instance : GArrowListDataType;
}
extern record _GArrowMapDataTypeClass {
  var parent_class : GArrowListDataTypeClass;
}
extern record _GArrowUnionDataType {
  var parent_instance : GArrowDataType;
}
extern record _GArrowUnionDataTypeClass {
  var parent_class : GArrowDataTypeClass;
}
extern record _GArrowSparseUnionDataType {
  var parent_instance : GArrowUnionDataType;
}
extern record _GArrowSparseUnionDataTypeClass {
  var parent_class : GArrowUnionDataTypeClass;
}
extern record _GArrowDenseUnionDataType {
  var parent_instance : GArrowUnionDataType;
}
extern record _GArrowDenseUnionDataTypeClass {
  var parent_class : GArrowUnionDataTypeClass;
}
extern record _GArrowDictionaryDataType {
  var parent_instance : GArrowFixedWidthDataType;
}
extern record _GArrowDictionaryDataTypeClass {
  var parent_class : GArrowFixedWidthDataTypeClass;
}
extern record _GArrowListArray {
  var parent_instance : GArrowArray;
}
extern record _GArrowListArrayClass {
  var parent_class : GArrowArrayClass;
}
extern record _GArrowLargeListArray {
  var parent_instance : GArrowArray;
}
extern record _GArrowLargeListArrayClass {
  var parent_class : GArrowArrayClass;
}
extern record _GArrowStructArray {
  var parent_instance : GArrowArray;
}
extern record _GArrowStructArrayClass {
  var parent_class : GArrowArrayClass;
}
extern record _GArrowMapArray {
  var parent_instance : GArrowListArray;
}
extern record _GArrowMapArrayClass {
  var parent_class : GArrowListArrayClass;
}
extern record _GArrowUnionArray {
  var parent_instance : GArrowArray;
}
extern record _GArrowUnionArrayClass {
  var parent_class : GArrowArrayClass;
}
extern record _GArrowSparseUnionArray {
  var parent_instance : GArrowUnionArray;
}
extern record _GArrowSparseUnionArrayClass {
  var parent_class : GArrowUnionArrayClass;
}
extern record _GArrowDenseUnionArray {
  var parent_instance : GArrowUnionArray;
}
extern record _GArrowDenseUnionArrayClass {
  var parent_class : GArrowUnionArrayClass;
}
extern record _GArrowDictionaryArray {
  var parent_instance : GArrowArray;
}
extern record _GArrowDictionaryArrayClass {
  var parent_class : GArrowArrayClass;
}
extern record _GArrowArrayBuilder {
  var parent_instance : GObject;
}
extern record _GArrowArrayBuilderClass {
  var parent_class : GObjectClass;
}
extern record _GArrowNullArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowNullArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowBooleanArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowBooleanArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowIntArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowIntArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowUIntArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowUIntArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowInt8ArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowInt8ArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowUInt8ArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowUInt8ArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowInt16ArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowInt16ArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowUInt16ArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowUInt16ArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowInt32ArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowInt32ArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowUInt32ArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowUInt32ArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowInt64ArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowInt64ArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowUInt64ArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowUInt64ArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowFloatArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowFloatArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowDoubleArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowDoubleArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowBinaryArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowBinaryArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowLargeBinaryArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowLargeBinaryArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowStringArrayBuilder {
  var parent_instance : GArrowBinaryArrayBuilder;
}
extern record _GArrowStringArrayBuilderClass {
  var parent_class : GArrowBinaryArrayBuilderClass;
}
extern record _GArrowLargeStringArrayBuilder {
  var parent_instance : GArrowLargeBinaryArrayBuilder;
}
extern record _GArrowLargeStringArrayBuilderClass {
  var parent_class : GArrowLargeBinaryArrayBuilderClass;
}
extern record _GArrowFixedSizeBinaryArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowFixedSizeBinaryArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowDate32ArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowDate32ArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowDate64ArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowDate64ArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowTimestampArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowTimestampArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowTime32ArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowTime32ArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowTime64ArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowTime64ArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowBinaryDictionaryArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowBinaryDictionaryArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowStringDictionaryArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowStringDictionaryArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowListArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowListArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowLargeListArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowLargeListArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowStructArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowStructArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowMapArrayBuilder {
  var parent_instance : GArrowArrayBuilder;
}
extern record _GArrowMapArrayBuilderClass {
  var parent_class : GArrowArrayBuilderClass;
}
extern record _GArrowDecimal128ArrayBuilder {
  var parent_instance : GArrowFixedSizeBinaryArrayBuilder;
}
extern record _GArrowDecimal128ArrayBuilderClass {
  var parent_class : GArrowFixedSizeBinaryArrayBuilderClass;
}
extern record _GArrowDecimal256ArrayBuilder {
  var parent_instance : GArrowFixedSizeBinaryArrayBuilder;
}
extern record _GArrowDecimal256ArrayBuilderClass {
  var parent_class : GArrowFixedSizeBinaryArrayBuilderClass;
}
extern record _GArrowChunkedArray {
  var parent_instance : GObject;
}
extern record _GArrowChunkedArrayClass {
  var parent_class : GObjectClass;
}
extern record _GArrowCodec {
  var parent_instance : GObject;
}
extern record _GArrowCodecClass {
  var parent_class : GObjectClass;
}
extern record _GArrowReadOptions {
  var parent_instance : GObject;
}
extern record _GArrowReadOptionsClass {
  var parent_class : GObjectClass;
}
extern record _GArrowWriteOptions {
  var parent_instance : GObject;
}
extern record _GArrowWriteOptionsClass {
  var parent_class : GObjectClass;
}
extern record _GArrowSchema {
  var parent_instance : GObject;
}
extern record _GArrowSchemaClass {
  var parent_class : GObjectClass;
}
extern record _GArrowRecordBatch {
  var parent_instance : GObject;
}
extern record _GArrowRecordBatchClass {
  var parent_class : GObjectClass;
}
extern record _GArrowRecordBatchIterator {
  var parent_instance : GObject;
}
extern record _GArrowRecordBatchIteratorClass {
  var parent_class : GObjectClass;
}
extern record _GArrowScalar {
  var parent_instance : GObject;
}
extern record _GArrowScalarClass {
  var parent_class : GObjectClass;
}
extern record _GArrowNullScalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowNullScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowBooleanScalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowBooleanScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowInt8Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowInt8ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowInt16Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowInt16ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowInt32Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowInt32ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowInt64Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowInt64ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowUInt8Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowUInt8ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowUInt16Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowUInt16ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowUInt32Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowUInt32ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowUInt64Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowUInt64ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowFloatScalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowFloatScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowDoubleScalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowDoubleScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowBaseBinaryScalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowBaseBinaryScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowBinaryScalar {
  var parent_instance : GArrowBaseBinaryScalar;
}
extern record _GArrowBinaryScalarClass {
  var parent_class : GArrowBaseBinaryScalarClass;
}
extern record _GArrowStringScalar {
  var parent_instance : GArrowBaseBinaryScalar;
}
extern record _GArrowStringScalarClass {
  var parent_class : GArrowBaseBinaryScalarClass;
}
extern record _GArrowLargeBinaryScalar {
  var parent_instance : GArrowBaseBinaryScalar;
}
extern record _GArrowLargeBinaryScalarClass {
  var parent_class : GArrowBaseBinaryScalarClass;
}
extern record _GArrowLargeStringScalar {
  var parent_instance : GArrowBaseBinaryScalar;
}
extern record _GArrowLargeStringScalarClass {
  var parent_class : GArrowBaseBinaryScalarClass;
}
extern record _GArrowFixedSizeBinaryScalar {
  var parent_instance : GArrowBaseBinaryScalar;
}
extern record _GArrowFixedSizeBinaryScalarClass {
  var parent_class : GArrowBaseBinaryScalarClass;
}
extern record _GArrowDate32Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowDate32ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowDate64Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowDate64ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowTime32Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowTime32ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowTime64Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowTime64ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowTimestampScalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowTimestampScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowDecimal128Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowDecimal128ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowDecimal256Scalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowDecimal256ScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowBaseListScalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowBaseListScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowListScalar {
  var parent_instance : GArrowBaseListScalar;
}
extern record _GArrowListScalarClass {
  var parent_class : GArrowBaseListScalarClass;
}
extern record _GArrowLargeListScalar {
  var parent_instance : GArrowBaseListScalar;
}
extern record _GArrowLargeListScalarClass {
  var parent_class : GArrowBaseListScalarClass;
}
extern record _GArrowMapScalar {
  var parent_instance : GArrowBaseListScalar;
}
extern record _GArrowMapScalarClass {
  var parent_class : GArrowBaseListScalarClass;
}
extern record _GArrowStructScalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowStructScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowUnionScalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowUnionScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GArrowSparseUnionScalar {
  var parent_instance : GArrowUnionScalar;
}
extern record _GArrowSparseUnionScalarClass {
  var parent_class : GArrowUnionScalarClass;
}
extern record _GArrowDenseUnionScalar {
  var parent_instance : GArrowUnionScalar;
}
extern record _GArrowDenseUnionScalarClass {
  var parent_class : GArrowUnionScalarClass;
}
extern record _GArrowExtensionScalar {
  var parent_instance : GArrowScalar;
}
extern record _GArrowExtensionScalarClass {
  var parent_class : GArrowScalarClass;
}
extern record _GInputVector {
  var buffer : gpointer;
  var size : gsize;
}
extern record _GInputMessage {
  var address : c_ptr(c_ptr(GSocketAddress));
  var vectors : c_ptr(GInputVector);
  var num_vectors : guint;
  var bytes_received : gsize;
  var flags : gint;
  var control_messages : c_ptr(c_ptr(c_ptr(GSocketControlMessage)));
  var num_control_messages : c_ptr(guint);
}
extern record _GOutputVector {
  var buffer : gconstpointer;
  var size : gsize;
}
extern record _GOutputMessage {
  var address : c_ptr(GSocketAddress);
  var vectors : c_ptr(GOutputVector);
  var num_vectors : guint;
  var bytes_sent : guint;
  var control_messages : c_ptr(c_ptr(GSocketControlMessage));
  var num_control_messages : guint;
}
extern record _GActionInterface {
  var g_iface : GTypeInterface;
  var get_name : c_ptr(c_fn_ptr);
  var get_parameter_type : c_ptr(c_fn_ptr);
  var get_state_type : c_ptr(c_fn_ptr);
  var get_state_hint : c_ptr(c_fn_ptr);
  var get_enabled : c_ptr(c_fn_ptr);
  var get_state : c_ptr(c_fn_ptr);
  var change_state : c_ptr(c_fn_ptr);
  var activate : c_ptr(c_fn_ptr);
}
extern record _GActionGroupInterface {
  var g_iface : GTypeInterface;
  var has_action : c_ptr(c_fn_ptr);
  var list_actions : c_ptr(c_fn_ptr);
  var get_action_enabled : c_ptr(c_fn_ptr);
  var get_action_parameter_type : c_ptr(c_fn_ptr);
  var get_action_state_type : c_ptr(c_fn_ptr);
  var get_action_state_hint : c_ptr(c_fn_ptr);
  var get_action_state : c_ptr(c_fn_ptr);
  var change_action_state : c_ptr(c_fn_ptr);
  var activate_action : c_ptr(c_fn_ptr);
  var action_added : c_ptr(c_fn_ptr);
  var action_removed : c_ptr(c_fn_ptr);
  var action_enabled_changed : c_ptr(c_fn_ptr);
  var action_state_changed : c_ptr(c_fn_ptr);
  var query_action : c_ptr(c_fn_ptr);
}
extern record _GActionMapInterface {
  var g_iface : GTypeInterface;
  var lookup_action : c_ptr(c_fn_ptr);
  var add_action : c_ptr(c_fn_ptr);
  var remove_action : c_ptr(c_fn_ptr);
}
extern record _GActionEntry {
  var name : c_ptr(gchar);
  var activate : c_ptr(c_fn_ptr);
  var parameter_type : c_ptr(gchar);
  var state : c_ptr(gchar);
  var change_state : c_ptr(c_fn_ptr);
  var padding : c_ptr(gsize);
}
extern record _GAppInfoIface {
  var g_iface : GTypeInterface;
  var dup : c_ptr(c_fn_ptr);
  var equal : c_ptr(c_fn_ptr);
  var get_id : c_ptr(c_fn_ptr);
  var get_name : c_ptr(c_fn_ptr);
  var get_description : c_ptr(c_fn_ptr);
  var get_executable : c_ptr(c_fn_ptr);
  var get_icon : c_ptr(c_fn_ptr);
  var launch : c_ptr(c_fn_ptr);
  var supports_uris : c_ptr(c_fn_ptr);
  var supports_files : c_ptr(c_fn_ptr);
  var launch_uris : c_ptr(c_fn_ptr);
  var should_show : c_ptr(c_fn_ptr);
  var set_as_default_for_type : c_ptr(c_fn_ptr);
  var set_as_default_for_extension : c_ptr(c_fn_ptr);
  var add_supports_type : c_ptr(c_fn_ptr);
  var can_remove_supports_type : c_ptr(c_fn_ptr);
  var remove_supports_type : c_ptr(c_fn_ptr);
  var can_delete : c_ptr(c_fn_ptr);
  var do_delete : c_ptr(c_fn_ptr);
  var get_commandline : c_ptr(c_fn_ptr);
  var get_display_name : c_ptr(c_fn_ptr);
  var set_as_last_used_for_type : c_ptr(c_fn_ptr);
  var get_supported_types : c_ptr(c_fn_ptr);
  var launch_uris_async : c_ptr(c_fn_ptr);
  var launch_uris_finish : c_ptr(c_fn_ptr);
}
extern record _GAppLaunchContext {
  var parent_instance : GObject;
  var priv : c_ptr(GAppLaunchContextPrivate);
}
extern record _GAppLaunchContextClass {
  var parent_class : GObjectClass;
  var get_display : c_ptr(c_fn_ptr);
  var get_startup_notify_id : c_ptr(c_fn_ptr);
  var launch_failed : c_ptr(c_fn_ptr);
  var launched : c_ptr(c_fn_ptr);
  var _g_reserved1 : c_ptr(c_fn_ptr);
  var _g_reserved2 : c_ptr(c_fn_ptr);
  var _g_reserved3 : c_ptr(c_fn_ptr);
  var _g_reserved4 : c_ptr(c_fn_ptr);
}
extern record _GApplication {
  var parent_instance : GObject;
  var priv : c_ptr(GApplicationPrivate);
}
extern record _GApplicationClass {
  var parent_class : GObjectClass;
  var startup : c_ptr(c_fn_ptr);
  var activate : c_ptr(c_fn_ptr);
  var open : c_ptr(c_fn_ptr);
  var command_line : c_ptr(c_fn_ptr);
  var local_command_line : c_ptr(c_fn_ptr);
  var before_emit : c_ptr(c_fn_ptr);
  var after_emit : c_ptr(c_fn_ptr);
  var add_platform_data : c_ptr(c_fn_ptr);
  var quit_mainloop : c_ptr(c_fn_ptr);
  var run_mainloop : c_ptr(c_fn_ptr);
  var shutdown : c_ptr(c_fn_ptr);
  var dbus_register : c_ptr(c_fn_ptr);
  var dbus_unregister : c_ptr(c_fn_ptr);
  var handle_local_options : c_ptr(c_fn_ptr);
  var name_lost : c_ptr(c_fn_ptr);
  var padding : c_ptr(gpointer);
}
extern record _GApplicationCommandLine {
  var parent_instance : GObject;
  var priv : c_ptr(GApplicationCommandLinePrivate);
}
extern record _GApplicationCommandLineClass {
  var parent_class : GObjectClass;
  var print_literal : c_ptr(c_fn_ptr);
  var printerr_literal : c_ptr(c_fn_ptr);
  var get_stdin : c_ptr(c_fn_ptr);
  var padding : c_ptr(gpointer);
}
extern record _GInitableIface {
  var g_iface : GTypeInterface;
  var init : c_ptr(c_fn_ptr);
}
extern record _GAsyncInitableIface {
  var g_iface : GTypeInterface;
  var init_async : c_ptr(c_fn_ptr);
  var init_finish : c_ptr(c_fn_ptr);
}
extern record _GAsyncResultIface {
  var g_iface : GTypeInterface;
  var get_user_data : c_ptr(c_fn_ptr);
  var get_source_object : c_ptr(c_fn_ptr);
  var is_tagged : c_ptr(c_fn_ptr);
}
extern record _GInputStream {
  var parent_instance : GObject;
  var priv : c_ptr(GInputStreamPrivate);
}
extern record _GInputStreamClass {
  var parent_class : GObjectClass;
  var read_fn : c_ptr(c_fn_ptr);
  var skip : c_ptr(c_fn_ptr);
  var close_fn : c_ptr(c_fn_ptr);
  var read_async : c_ptr(c_fn_ptr);
  var read_finish : c_ptr(c_fn_ptr);
  var skip_async : c_ptr(c_fn_ptr);
  var skip_finish : c_ptr(c_fn_ptr);
  var close_async : c_ptr(c_fn_ptr);
  var close_finish : c_ptr(c_fn_ptr);
  var _g_reserved1 : c_ptr(c_fn_ptr);
  var _g_reserved2 : c_ptr(c_fn_ptr);
  var _g_reserved3 : c_ptr(c_fn_ptr);
  var _g_reserved4 : c_ptr(c_fn_ptr);
  var _g_reserved5 : c_ptr(c_fn_ptr);
}
extern record _GFilterInputStream {
  var parent_instance : GInputStream;
  var base_stream : c_ptr(GInputStream);
}
extern record _GFilterInputStreamClass {
  var parent_class : GInputStreamClass;
  var _g_reserved1 : c_ptr(c_fn_ptr);
  var _g_reserved2 : c_ptr(c_fn_ptr);
  var _g_reserved3 : c_ptr(c_fn_ptr);
}
extern record _GBufferedInputStream {
  var parent_instance : GFilterInputStream;
  var priv : c_ptr(GBufferedInputStreamPrivate);
}
extern record _GBufferedInputStreamClass {
  var parent_class : GFilterInputStreamClass;
  var fill : c_ptr(c_fn_ptr);
  var fill_async : c_ptr(c_fn_ptr);
  var fill_finish : c_ptr(c_fn_ptr);
  var _g_reserved1 : c_ptr(c_fn_ptr);
  var _g_reserved2 : c_ptr(c_fn_ptr);
  var _g_reserved3 : c_ptr(c_fn_ptr);
  var _g_reserved4 : c_ptr(c_fn_ptr);
  var _g_reserved5 : c_ptr(c_fn_ptr);
}
extern record _GOutputStream {
  var parent_instance : GObject;
  var priv : c_ptr(GOutputStreamPrivate);
}
extern record _GOutputStreamClass {
  var parent_class : GObjectClass;
  var write_fn : c_ptr(c_fn_ptr);
  var splice : c_ptr(c_fn_ptr);
  var flush : c_ptr(c_fn_ptr);
  var close_fn : c_ptr(c_fn_ptr);
  var write_async : c_ptr(c_fn_ptr);
  var write_finish : c_ptr(c_fn_ptr);
  var splice_async : c_ptr(c_fn_ptr);
  var splice_finish : c_ptr(c_fn_ptr);
  var flush_async : c_ptr(c_fn_ptr);
  var flush_finish : c_ptr(c_fn_ptr);
  var close_async : c_ptr(c_fn_ptr);
  var close_finish : c_ptr(c_fn_ptr);
  var writev_fn : c_ptr(c_fn_ptr);
  var writev_async : c_ptr(c_fn_ptr);
  var writev_finish : c_ptr(c_fn_ptr);
  var _g_reserved4 : c_ptr(c_fn_ptr);
  var _g_reserved5 : c_ptr(c_fn_ptr);
  var _g_reserved6 : c_ptr(c_fn_ptr);
  var _g_reserved7 : c_ptr(c_fn_ptr);
  var _g_reserved8 : c_ptr(c_fn_ptr);
}
extern record _GFilterOutputStream {
  var parent_instance : GOutputStream;
  var base_stream : c_ptr(GOutputStream);
}
extern record _GFilterOutputStreamClass {
  var parent_class : GOutputStreamClass;
  var _g_reserved1 : c_ptr(c_fn_ptr);
  var _g_reserved2 : c_ptr(c_fn_ptr);
  var _g_reserved3 : c_ptr(c_fn_ptr);
}
extern record _GBufferedOutputStream {
  var parent_instance : GFilterOutputStream;
  var priv : c_ptr(GBufferedOutputStreamPrivate);
}
extern record _GBufferedOutputStreamClass {
  var parent_class : GFilterOutputStreamClass;
  var _g_reserved1 : c_ptr(c_fn_ptr);
  var _g_reserved2 : c_ptr(c_fn_ptr);
}
extern record _GCancellable {
  var parent_instance : GObject;
  var priv : c_ptr(GCancellablePrivate);
}
extern record _GCancellableClass {
  var parent_class : GObjectClass;
  var cancelled : c_ptr(c_fn_ptr);
  var _g_reserved1 : c_ptr(c_fn_ptr);
  var _g_reserved2 : c_ptr(c_fn_ptr);
  var _g_reserved3 : c_ptr(c_fn_ptr);
  var _g_reserved4 : c_ptr(c_fn_ptr);
  var _g_reserved5 : c_ptr(c_fn_ptr);
}
extern record _GConverterIface {
  var g_iface : GTypeInterface;
  var convert : c_ptr(c_fn_ptr);
  var reset : c_ptr(c_fn_ptr);
}
extern record _GCharsetConverterClass {
  var parent_class : GObjectClass;
}
extern record _GConverterInputStream {
  var parent_instance : GFilterInputStream;
  var priv : c_ptr(GConverterInputStreamPrivate);
}
extern record _GConverterInputStreamClass {
  var parent_class : GFilterInputStreamClass;
  var _g_reserved1 : c_ptr(c_fn_ptr);
  var _g_reserved2 : c_ptr(c_fn_ptr);
  var _g_reserved3 : c_ptr(c_fn_ptr);
  var _g_reserved4 : c_ptr(c_fn_ptr);
  var _g_reserved5 : c_ptr(c_fn_ptr);
}
extern record _GConverterOutputStream {
  var parent_instance : GFilterOutputStream;
  var priv : c_ptr(GConverterOutputStreamPrivate);
}
extern record _GConverterOutputStreamClass {
  var parent_class : GFilterOutputStreamClass;
  var _g_reserved1 : c_ptr(c_fn_ptr);
  var _g_reserved2 : c_ptr(c_fn_ptr);
  var _g_reserved3 : c_ptr(c_fn_ptr);
  var _g_reserved4 : c_ptr(c_fn_ptr);
  var _g_reserved5 : c_ptr(c_fn_ptr);
}
extern record _GDatagramBasedInterface {
  var g_iface : GTypeInterface;
  var receive_messages : c_ptr(c_fn_ptr);
  var send_messages : c_ptr(c_fn_ptr);
  var create_source : c_ptr(c_fn_ptr);
  var condition_check : c_ptr(c_fn_ptr);
  var condition_wait : c_ptr(c_fn_ptr);
}
extern record _GDataInputStream {
  var parent_instance : GBufferedInputStream;
  var priv : c_ptr(GDataInputStreamPrivate);
}
extern record _GDataInputStreamClass {
  var parent_class : GBufferedInputStreamClass;
  var _g_reserved1 : c_ptr(c_fn_ptr);
  var _g_reserved2 : c_ptr(c_fn_ptr);
  var _g_reserved3 : c_ptr(c_fn_ptr);
  var _g_reserved4 : c_ptr(c_fn_ptr);
  var _g_reserved5 : c_ptr(c_fn_ptr);
}
extern record _GDataOutputStream {
  var parent_instance : GFilterOutputStream;
  var priv : c_ptr(GDataOutputStreamPrivate);
}
extern record _GDataOutputStreamClass {
  var parent_class : GFilterOutputStreamClass;
  var _g_reserved1 : c_ptr(c_fn_ptr);
  var _g_reserved2 : c_ptr(c_fn_ptr);
  var _g_reserved3 : c_ptr(c_fn_ptr);
  var _g_reserved4 : c_ptr(c_fn_ptr);
  var _g_reserved5 : c_ptr(c_fn_ptr);
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
