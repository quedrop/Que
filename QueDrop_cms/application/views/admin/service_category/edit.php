<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold"><?php _el('edit_service_category'); ?></span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li><a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a></li>
			<li><a href="<?php echo base_url('admin/service_category'); ?>"><?php _el('service_category'); ?></a></li>
			<li class="active"><?php _el('edit'); ?></li>
		</ul>
	</div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
	<form action="<?php echo base_url('admin/servicecategory/edit/').$category['service_category_id']; ?>" id="categoryform" method="POST" enctype="multipart/form-data">
		<div class="row">		
			<div class="col-md-8 col-md-offset-2">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong><?php _el('service_category'); ?></strong>
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
									<label><?php _el('service_category_name'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('service_category_name'); ?>" id="name" name="name" value="<?php echo $category['service_category_name']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger"></small>
									<label><?php _el('service_cat_image'); ?>:</label>
									<input type="file" class="form-control" id="category_image" name="category_image" accept=".png, .jpg, .jpeg">
									<input type="hidden" name="old_image" id="old_image" value="<?php echo $category['service_category_image'];?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label><?php _el('service_category_description'); ?>:</label>
									<textarea class="form-control" name="category_description" rows="5"><?php echo $category['service_category_description'];?></textarea>
                                </div>

								<div class="form-group">
									<label><?php _el('status'); ?>:</label>	
										<input type="checkbox" class="switchery" name="is_active" id="<?php echo $category['service_category_id']; ?>" <?php if ($category['is_active'] == 1) {
										echo "checked";
										}  ?>>								
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

<script type="text/javascript">
$.validator.addMethod('filesize', function (value, element, param) {
    return this.optional(element) || (element.files[0].size <= param)
}, 'File size must be less than {0}');
$("#categoryform").validate({
	rules: {
		name:
		{
			required: true,		
		},
		category_image:{
			filesize: 2097152,
		},
		category_description:{
			required:true
		}
	},
	messages: {
		name: 
		{
			required:"<?php _el('please_enter_', _l('category_name')) ?>",
		},   
		category_image: {
            filesize:"file size must be less than 2 MB.",
        }, 
		category_description:{
			required:"Please enter Store Service Category Description",
		}    
	}
});  
</script>

