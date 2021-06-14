<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold">Add Fresh Produce Category</span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li><a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a></li>
			<li><a href="<?php echo base_url('admin/fresh_produce_category'); ?>">Fresh Produce Category</a></li>
			<li class="active"><?php _el('add'); ?></li>
		</ul>
	</div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
	<form action="<?php echo base_url('admin/fresh_produce_category/add'); ?>" id="categoryform" method="POST" enctype="multipart/form-data">
		<div class="row">		
			<div class="col-md-8 col-md-offset-2">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Fresh Produce Category</strong>
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
									<label>Fresh Produce Category Title:</label>
									<input type="text" class="form-control" placeholder="Fresh Produce Category Title" id="fresh_produce_title" name="fresh_produce_title">
								</div>
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label>Fresh Produce Category Image:</label>
									<input type="file" class="form-control" id="fresh_produce_image" name="fresh_produce_image" accept=".png, .jpg, .jpeg">
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
		fresh_produce_title:
		{
			required: true,		
		},
		fresh_produce_image:{
            required:true,
			filesize: 2097152,
		},
	},
	messages: {
		fresh_produce_title: 
		{
			required:"<?php _el('please_enter_', 'Fresh Produce Category Title') ?>",
		},   
		fresh_produce_image: {
            required:"Please upload Fresh Produce Category Image",
            filesize:"file size must be less than 2 MB.",
        }, 
	}
});  
</script>

