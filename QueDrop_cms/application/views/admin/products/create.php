<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold"><?php _el('add_product'); ?></span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
			</li>
			<li>
				<a href="<?php echo base_url('admin/products'); ?>"><?php _el('products'); ?></a>
			</li>
			<li class="active"><?php _el('add'); ?></li>
		</ul>
	</div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
	<form action="<?php echo base_url('admin/products/add'); ?>" id="productform" method="POST" enctype="multipart/form-data">
		<div class="row">
			<div class="col-md-8 col-md-offset-2">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong><?php _el('product'); ?></strong>
								</h5>
							</div>
						</div>
					</div>
					<!-- /Panel heading -->
					<!-- Panel body -->
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12">
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label><?php _el('product_name'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('product_name'); ?>" id="name" name="name">
								</div>
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label><?php _el('description'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('description'); ?>" id="description" name="description">
								</div>
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label>Store:</label>
									<select name="store" id="store" class="select" onchange="get_category(this.value);">
										<option value="">Select Store</option>
										<?php 
										if(!empty($store)) {
											foreach($store as $cat) {
											?>
											<option value="<?php echo $cat['store_id'];?>"><?php echo $cat['store_name'];?></option>
											<?php
											}
										}
										?>
									</select>
								</div>
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label><?php _el('category'); ?>:</label>
									<select name="category" id="category" class="select">
										<option value="">Select Food Category</option>
									</select>
								</div>
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label><?php _el('product_image'); ?>:</label>
									<input type="file" class="form-control" name="product_image" id="product_image" accept=".png, .jpg, .jpeg">
								</div>
								<!-- <div class="form-group">
									<small class="req text-danger">*</small>
									<label><?php _el('price'); ?>:</label>
									
								</div> -->
								<input type="hidden" class="form-control" placeholder="<?php _el('price'); ?>" id="price" name="price">
								<div class="form-group">
									<label><?php _el('extra_fees'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('extra_fees'); ?>" id="extra_fees" name="extra_fees">
								</div>
								<div class="form-group">
									<label>Product Options:</label>
									<a id="add-btn" class="btn btn-primary" onclick="add_option(1);">Add Option<i class="icon-plus-circle2 position-right"></i></a>
								</div>
								<div class="option_div">
									<table id="option">
										<tr>
											<th>Product Option</th>
											<th>Price</th>
											<th>Is default</th>
											<th></th>
										</tr>
										<tbody id="op_body">
											<tr id="1">
												<td>
													<input type="text" name="option[]" placeholder="Ex. Small,Medium,Large,1 kg,500 gm" class="form-control">
												</td>
												<td>
													<input type="text" name="option_price[]" placeholder="100" class="form-control">
												</td>
												<td>
													<input type="radio" class="form-control rd_st" name="rd_chk"  id="rd_st_1" onchange="check_val(1);" checked>
													<input type="hidden" name="is_default[]" id="def_1" value="1" class="chk_de">
												</td>
											</tr>
										</tbody>
									</table>
								</div>
								<div class="form-group">
									<label>Product Addons:</label>
									<a id="addon-btn" class="btn btn-primary" onclick="add_addons(1);">Add Addons<i class="icon-plus-circle2 position-right"></i></a>
								</div>
								<div class="option_div">
									<table id="option">
										<tr>
											<th>Addon Name</th>
											<th>Price</th>
											<th></th>
										</tr>
										<tbody id="ad_body">
											<tr id="add_1">
												<td>
													<input type="text" name="addob_name[]" placeholder="Ex. Extra Cheese,Red Peprika,Cheese Dip" class="form-control">
												</td>
												<td>
													<input type="text" name="addon_price[]" placeholder="100" class="form-control">
												</td>
											</tr>
										</tbody>
									</table>
								</div>
								<div class="form-group">
									<label>Product Verified : </label>&nbsp;&nbsp;
									<input type="checkbox" class="styled" name="is_verified">
								</div>
							</div>
						</div>
					</div>	
					<!-- /Panel body -->
				</div>
				<!-- /Panel -->
			</div>
		</div>
		<div class="btn-bottom-toolbar text-right btn-toolbar-container-out">
		<button type="submit" class="btn btn-success" name="submit"><?php _el('save'); ?></button>
		<a class="btn btn-default" onclick="window.history.back();"><?php _el('back'); ?></a>
		</div>
	</form>
</div>
<!-- /Content area -->

<style>
#option {
  font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

#option td, #option th {
  padding: 8px;
}

.rd_st{
	width: 25%;
    margin-left: 30% !important;
}
</style>

<script type="text/javascript">
$.validator.addMethod('filesize', function (value, element, param) {
    return this.optional(element) || (element.files[0].size <= param)
}, 'File size must be less than {0}');
$("#productform").validate({
	rules: {
		name:
		{
			required: true,
		},
		description:{
			required:true,
		},
		store:{
			required:true,
		},
		category:{
			required:true,
		},
		// price:{
		// 	required:true,
		// 	number:true,
		// },
		product_image:{
			required:true,
			filesize: 2097152,
		},
		extra_fees:{
			number:true,
		},
		'option_price[]':{
			number:true,
			required:true,
		},
		'addon_price[]':{
			number:true,
		},
	},
	messages: {
		name: 
		{
			required:"<?php _el('please_enter_', _l('product_name')) ?>",
		},
		description:
		{
			required:"<?php _el('please_enter_', _l('description')) ?>",
		},
		category:{
			required:"<?php _el('please_enter_', _l('category')) ?>",
		},
		store:{
			required:"Please select Store",
		},
		// price:{
		// 	required:"<?php _el('please_enter_', _l('price')) ?>",
		// 	number:"Please Enter Valid Price",
		// },
		product_image:{
			required:"Please upload Product Image",
			filesize:"file size must be less than 2 MB.",
		},
		extra_fees:{
			number:"Please Enter Valid Extra Fees",
		},
		'option_price[]':{
			number:"Please Enter Valid Price",
			required:"Please Add Price",
		},
		'addon_price[]':{
			number:"Please Enter Valid Price",
		}
		
	}
});

var BASE_URL = "<?php echo base_url(); ?>";

function add_addons(id){
	var new_id = parseInt(id+1);
	var html = '<tr id="add_'+new_id+'"><td><input type="text" name="addob_name[]" placeholder="Ex. Extra Cheese,Red Peprika,Cheese Dip" class="form-control"></td><td><input type="text" name="addon_price[]" placeholder="100" class="form-control"></td><td><a data-popup="tooltip" data-placement="top" href="javascript:delete_addons('+new_id+');" class="text-danger delete"><i class=" icon-trash"></i></a></td></tr>';
	// $("#add_"+id).after(html);
	$("#ad_body").append(html);
	$("#addon-btn").attr("onclick","add_addons("+new_id+")");
}

function delete_addons(id){
	$("#add_"+id).remove();
}

function add_option(id)
{
	var new_id = parseInt(id+1);
	var html = '<tr id="'+new_id+'"><td><input type="text" name="option[]" placeholder="Ex. Small,Medium,Large,1 kg,500 gm" class="form-control"></td><td><input type="text" name="option_price[]" placeholder="100" class="form-control"></td><td><div class="rd_checked"><span id="check_'+new_id+'" ><input type="radio" class="form-control rd_st" name="rd_chk" id="rd_st_'+new_id+'" onchange="check_val('+new_id+');"><input type="hidden" name="is_default[]" id="def_'+new_id+'" value="0" class="chk_de"></span></div></td><td><a data-popup="tooltip" data-placement="top" href="javascript:delete_option('+new_id+');" class="text-danger delete"><i class=" icon-trash"></i></a></td></tr>';
	// $("#"+id).after(html);
	$("#op_body").append(html);
	$("#add-btn").attr("onclick","add_option("+new_id+")");
}

function check_val(id){
	$(".chk_de").val(0);
	if($("#rd_st_"+id).is(':checked')){
		$("#def_"+id).val(1);
	} else {
		$("#def_"+id).val(0);
	}
}

function delete_option(id){
	$("#"+id).remove();
}

function get_category(id) {
	$.ajax({
        url:BASE_URL+'admin/products/get_category',
        type: 'POST',
        data: { id: id },
        async: false,
        success: function(data) 
        {   
            if(data != ''){
				$("#category").empty();
				$("#category").append(data);
			}
        }
    });
}
</script>

